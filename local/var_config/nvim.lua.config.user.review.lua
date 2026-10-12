-- Branch review tab: changed files on the left, a delta diff on the right, and opencode (via sidekick) along the bottom
local M = {}

local SIDEKICK_TOOL = "opencode_review"

local function notify(msg, level)
	vim.notify(msg, level or vim.log.levels.WARN, { title = "Review" })
end

local function git(root, args)
	local cmd = { "git", "-C", root }
	vim.list_extend(cmd, args)
	local res = vim.system(cmd, { text = true }):wait()
	if res.code ~= 0 then
		return nil, vim.trim(res.stderr or "")
	end
	return vim.trim(res.stdout or "")
end

-- Commits on HEAD that aren't on ref, nil if ref doesn't resolve
local function commits_ahead(root, ref)
	return tonumber(git(root, { "rev-list", "--count", ref .. "..HEAD" }) or "")
end

-- The upstream only counts as a base when it tracks a differently named branch and HEAD has commits past it. A
-- same-named upstream (e.g. a contributor's fork for a PR) is just where the branch syncs, and gives an empty diff.
local function usable_upstream(root)
	local branch = git(root, { "symbolic-ref", "--quiet", "--short", "HEAD" })
	local upstream = branch and git(root, { "rev-parse", "--abbrev-ref", "--symbolic-full-name", "@{u}" })
	if not upstream then
		return
	end
	if git(root, { "config", "--get", "branch." .. branch .. ".merge" }) == "refs/heads/" .. branch then
		return
	end
	if (commits_ahead(root, upstream) or 0) == 0 then
		return
	end
	return upstream
end

-- Of the likely default branches, pick the one HEAD forked from most recently, since stale remotes fork much further back
local function nearest_default_branch(root)
	local candidates = {}
	for _, remote in ipairs({ "origin", "upstream" }) do
		local head = git(root, { "symbolic-ref", "--quiet", "--short", "refs/remotes/" .. remote .. "/HEAD" })
		if head then
			table.insert(candidates, head)
		end
		vim.list_extend(candidates, { remote .. "/main", remote .. "/master" })
	end
	vim.list_extend(candidates, { "main", "master" })

	-- Ties go to the earlier candidate. If HEAD has no commits of its own, fall back to the first one that resolves.
	local best, best_ahead, fallback
	for _, candidate in ipairs(candidates) do
		local ahead = commits_ahead(root, candidate)
		if ahead then
			fallback = fallback or candidate
			if ahead > 0 and (not best_ahead or ahead < best_ahead) then
				best, best_ahead = candidate, ahead
			end
		end
	end
	return best or fallback
end

-- In order of precedence: an explicit ref, a usable upstream, then the nearest default branch
local function resolve_base(root, ref)
	if ref and ref ~= "" then
		return ref
	end
	return usable_upstream(root) or nearest_default_branch(root)
end

-- A tab with a single empty, unnamed buffer (i.e. a fresh `nvim` from the git alias) gets reused instead of tabnew'd
local function tab_is_pristine()
	if #vim.api.nvim_tabpage_list_wins(0) ~= 1 then
		return false
	end
	local buf = vim.api.nvim_get_current_buf()
	return vim.api.nvim_buf_get_name(buf) == ""
		and vim.bo[buf].buftype == ""
		and not vim.bo[buf].modified
		and vim.api.nvim_buf_line_count(buf) == 1
		and vim.api.nvim_buf_get_lines(buf, 0, 1, false)[1] == ""
end

-- {{{ ANSI to highlights
-- A terminal buffer would do the coloring for us, but it hard-wraps at the window width and reflows (badly) on resize,
-- so instead we strip the escape codes into a plain buffer and put the colors back as extmarks.
local ns = vim.api.nvim_create_namespace("user_review_ansi")
local hl_specs = {}

-- xterm's defaults, used when the colorscheme doesn't set g:terminal_color_N
local BASIC = {
	"#000000", "#cd0000", "#00cd00", "#cdcd00", "#0000ee", "#cd00cd", "#00cdcd", "#e5e5e5",
	"#7f7f7f", "#ff0000", "#00ff00", "#ffff00", "#5c5cff", "#ff00ff", "#00ffff", "#ffffff",
}

local function color_256(n)
	if n < 16 then
		return vim.g["terminal_color_" .. n] or BASIC[n + 1]
	elseif n < 232 then
		n = n - 16
		local level = function(c)
			return c == 0 and 0 or 55 + c * 40
		end
		return ("#%02x%02x%02x"):format(level(math.floor(n / 36)), level(math.floor(n / 6) % 6), level(n % 6))
	end
	local v = 8 + (n - 232) * 10
	return ("#%02x%02x%02x"):format(v, v, v)
end

-- Mutates state according to one SGR sequence's parameters
local function apply_sgr(state, params)
	if #params == 0 then
		params = { 0 }
	end
	local i = 1
	while i <= #params do
		local p = params[i]
		if p == 0 then
			for k in pairs(state) do
				state[k] = nil
			end
		elseif p == 1 then
			state.bold = true
		elseif p == 3 then
			state.italic = true
		elseif p == 4 then
			state.underline = true
		elseif p == 7 then
			state.reverse = true
		elseif p == 9 then
			state.strikethrough = true
		elseif p == 22 then
			state.bold = nil
		elseif p == 23 then
			state.italic = nil
		elseif p == 24 then
			state.underline = nil
		elseif p == 27 then
			state.reverse = nil
		elseif p == 29 then
			state.strikethrough = nil
		elseif p >= 30 and p <= 37 then
			state.fg = color_256(p - 30)
		elseif p >= 90 and p <= 97 then
			state.fg = color_256(p - 90 + 8)
		elseif p >= 40 and p <= 47 then
			state.bg = color_256(p - 40)
		elseif p >= 100 and p <= 107 then
			state.bg = color_256(p - 100 + 8)
		elseif p == 39 then
			state.fg = nil
		elseif p == 49 then
			state.bg = nil
		elseif p == 38 or p == 48 then
			local color
			if params[i + 1] == 2 then
				color = ("#%02x%02x%02x"):format(params[i + 2] or 0, params[i + 3] or 0, params[i + 4] or 0)
				i = i + 4
			elseif params[i + 1] == 5 then
				color = color_256(params[i + 2] or 0)
				i = i + 2
			end
			state[p == 38 and "fg" or "bg"] = color
		end
		i = i + 1
	end
end

-- One highlight group per distinct combination of attributes, created on first use
local function hl_group(state)
	if next(state) == nil then
		return nil
	end
	local keys = vim.tbl_keys(state)
	table.sort(keys)
	local parts = {}
	for _, k in ipairs(keys) do
		parts[#parts + 1] = k .. tostring(state[k]):gsub("#", "")
	end
	local name = "ReviewAnsi_" .. table.concat(parts, "_")
	if not hl_specs[name] then
		hl_specs[name] = vim.deepcopy(state)
		vim.api.nvim_set_hl(0, name, hl_specs[name])
	end
	return name
end

-- A colorscheme change clears every group, ours included
vim.api.nvim_create_autocmd("ColorScheme", {
	group = vim.api.nvim_create_augroup("user_review_ansi", { clear = true }),
	callback = function()
		for name, spec in pairs(hl_specs) do
			vim.api.nvim_set_hl(0, name, spec)
		end
	end,
})

-- Returns the plain lines plus the highlight spans as { row, start_col, end_col, group, eol }
local function parse_ansi(text)
	-- OSC sequences (e.g. delta's hyperlinks) carry no color, so they just get dropped
	text = text:gsub("\27%].-\27\\", ""):gsub("\27%].-\7", "")
	local lines, spans, state = {}, {}, {}
	for row, raw in ipairs(vim.split(text, "\r?\n")) do
		local plain, pos = {}, 1
		local col, group, group_start = 0, hl_group(state), 0
		local function flush()
			if group and col > group_start then
				spans[#spans + 1] = { row - 1, group_start, col, group }
			end
			group_start = col
		end
		while true do
			local s, e, params, cmd = raw:find("\27%[([%d;]*)(%a)", pos)
			local chunk = raw:sub(pos, (s or 0) - 1)
			if not s then
				chunk = raw:sub(pos)
			end
			plain[#plain + 1] = chunk
			col = col + #chunk
			if not s then
				break
			end
			if cmd == "m" then
				-- An empty parameter means 0, which is also how a bare ESC[m resets
				local nums = {}
				for n in (params .. ";"):gmatch("([^;]*);") do
					nums[#nums + 1] = tonumber(n) or 0
				end
				flush()
				apply_sgr(state, nums)
				group = hl_group(state)
			elseif cmd == "K" and state.bg then
				-- Delta paints whole-line backgrounds with erase-to-end-of-line
				spans[#spans + 1] = { row - 1, col, nil, hl_group({ bg = state.bg }), true }
			end
			pos = e + 1
		end
		flush()
		lines[row] = table.concat(plain)
	end
	if lines[#lines] == "" then
		lines[#lines] = nil
	end
	return lines, spans
end
-- }}}

-- Renders delta's output into a plain read-only scratch buffer in the current window, with the colors as extmarks
local function start_delta(merge_base)
	local buf = vim.api.nvim_get_current_buf()
	local win = vim.api.nvim_get_current_win()
	-- The text area, minus number and sign columns, so delta's rules don't wrap
	local width = vim.api.nvim_win_get_width(win) - vim.fn.getwininfo(win)[1].textoff

	vim.bo[buf].buftype = "nofile"
	vim.bo[buf].bufhidden = "wipe"
	vim.bo[buf].buflisted = false
	vim.bo[buf].swapfile = false
	vim.bo[buf].modifiable = false

	-- Without a tty delta can't detect the theme, so we follow nvim's
	local script = [[
		{
			git --no-pager diff --color=always --stat="$2" --summary "$1"
			echo
			git --no-pager diff "$1"
		} | delta --paging=never --width="$3" "$4"
	]]
	local theme = vim.o.background == "light" and "--light" or "--dark"
	local cmd = { "sh", "-c", script, "sh", merge_base, tostring(math.max(width - 2, 40)), tostring(width), theme }

	vim.system(cmd, { text = true }, function(res)
		vim.schedule(function()
			if not vim.api.nvim_buf_is_valid(buf) then
				return
			end
			local out = res.code == 0 and res.stdout or ("delta failed:\n" .. (res.stderr or ""))
			local lines, spans = parse_ansi(out)

			vim.bo[buf].modifiable = true
			vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
			vim.bo[buf].modifiable = false
			vim.bo[buf].modified = false

			for _, span in ipairs(spans) do
				local row, start_col, end_col, group, eol = unpack(span)
				if eol then
					-- Fills from here to the window edge, under any text highlights on the same line
					vim.api.nvim_buf_set_extmark(buf, ns, row, start_col, {
						end_row = row + 1,
						end_col = 0,
						hl_group = group,
						hl_eol = true,
						priority = 90,
						strict = false,
					})
				else
					vim.api.nvim_buf_set_extmark(buf, ns, row, start_col, {
						end_col = end_col,
						hl_group = group,
						priority = 100,
						strict = false,
					})
				end
			end
		end)
	end)
end

function M.open(ref)
	local root, err = git(vim.fn.getcwd(), { "rev-parse", "--show-toplevel" })
	if not root then
		return notify("Not in a git repo: " .. err)
	end

	local base = resolve_base(root, ref)
	if not base then
		return notify("Couldn't figure out a base branch, pass one with :Review <ref>")
	end

	local merge_base
	merge_base, err = git(root, { "merge-base", base, "HEAD" })
	if not merge_base then
		return notify(("No merge base between %s and HEAD: %s"):format(base, err))
	end

	-- Merge base against the working tree, so uncommitted edits are included. Deleted files have nothing to open.
	local out = git(root, { "diff", "--name-only", "--diff-filter=d", merge_base }) or ""
	local files = vim.split(out, "\n", { trimempty = true })
	if #files == 0 then
		return notify(
			("No changes against %s (merge base %s), pass a different base with `git rv <ref>` or `:Review <ref>`"):format(
				base,
				merge_base:sub(1, 8)
			),
			vim.log.levels.INFO
		)
	end

	if not tab_is_pristine() then
		vim.cmd.tabnew()
	end
	-- Either nvim's startup buffer or the one tabnew made, it'd otherwise linger in barbar
	local scratch = vim.api.nvim_get_current_buf()
	vim.cmd.tcd(vim.fn.fnameescape(root))
	vim.t.review = { base = base, merge_base = merge_base }

	for _, file in ipairs(files) do
		vim.cmd.badd(vim.fn.fnameescape(file))
	end
	vim.cmd.edit(vim.fn.fnameescape(files[1]))
	pcall(vim.api.nvim_buf_delete, scratch, {})
	local left = vim.api.nvim_get_current_win()

	vim.cmd("rightbelow vnew")
	start_delta(merge_base)

	-- Sidekick opens its window asynchronously, focus = false keeps it from stealing the cursor when it does
	require("sidekick.cli").show({ name = SIDEKICK_TOOL, focus = false })
	vim.api.nvim_set_current_win(left)

	notify(("Reviewing %d file(s) against %s"):format(#files, base), vim.log.levels.INFO)
end

-- Used by the sidekick toggle keys so that inside a review tab they go to the review session instead of prompting
function M.sidekick_filter()
	if vim.t.review then
		return { name = SIDEKICK_TOOL }
	end
end

local function complete_refs(lead)
	local out = git(vim.fn.getcwd(), { "for-each-ref", "--format=%(refname:short)", "refs/heads", "refs/remotes" })
	return vim.tbl_filter(function(r)
		return vim.startswith(r, lead)
	end, vim.split(out or "", "\n", { trimempty = true }))
end

vim.api.nvim_create_user_command("Review", function(opts)
	M.open(opts.args)
end, {
	nargs = "?",
	complete = complete_refs,
	desc = "Open a branch review tab (files, delta diff, opencode)",
})

-- Once the last review tab is gone, detach its opencode so the regular sidekick toggle stops offering it
vim.api.nvim_create_autocmd("TabClosed", {
	group = vim.api.nvim_create_augroup("user_review", { clear = true }),
	callback = function()
		for _, tab in ipairs(vim.api.nvim_list_tabpages()) do
			if vim.t[tab].review then
				return
			end
		end
		if package.loaded["sidekick.cli"] then
			require("sidekick.cli").close({ name = SIDEKICK_TOOL })
		end
	end,
})

return M

-- vim: fdm=marker ts=2 sw=2 sts=2 noet
