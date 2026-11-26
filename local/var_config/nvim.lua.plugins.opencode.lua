-- opencode runs in a snacks terminal split, opencode.nvim talks to it over its HTTP API
local OPENCODE_CMD = "opencode"
local TERM_OPTS = {
	-- Pinned so that a count in front of a mapping doesn't spin up a second terminal
	count = 1,
	-- nvim's :terminal does 24-bit color but doesn't advertise it, so opencode would otherwise fall back to 256 colors
	env = { COLORTERM = "truecolor" },
	win = {
		position = "right",
		width = 0.5,
		-- Only the toggle should steal focus, not opencode.nvim starting it in the background
		enter = false,
		-- snacks maps Normal to NormalFloat, which gives opencode a lighter background than the rest of nvim
		wo = { winhighlight = "" },
	},
}

-- Inside a review tab (see config/user/review.lua) we want its own opencode instead of the regular one
local function terminal()
	local review = require("config.user.review").opencode_terminal()
	if review then
		return review.cmd, review.opts
	end
	return OPENCODE_CMD, TERM_OPTS
end

local function toggle()
	local term, created = Snacks.terminal.get(terminal())
	if not created then
		if term:on_current_tab() then
			return term:hide()
		end
		-- Still open in another tab, which would otherwise make toggle close it over there
		if term:win_valid() then
			term:hide()
		end
		term:show()
	end
	term:focus()
end

-- {{{ Terminal colors
-- opencode's "system" theme builds itself from the terminal's fg/bg (OSC 10/11) and palette (OSC 4), but nvim's
-- :terminal reports a fake black/white for 10/11 and ignores OSC 4. So we ask the real terminal once at startup and
-- answer opencode's queries with that, falling back to nvim's own Normal colors and terminal palette.
local host_colors = {}

local function to_osc_rgb(color)
	if type(color) == "string" then
		color = vim.api.nvim_get_color_by_name(color)
	end
	if not color or color < 0 then
		return nil
	end
	return ("rgb:%02x/%02x/%02x"):format(bit.rshift(color, 16), bit.band(bit.rshift(color, 8), 0xff), bit.band(color, 0xff))
end

-- `key` is the OSC query minus its "?", e.g. "11" or "4;3"
local function color_for(key)
	if host_colors[key] then
		return host_colors[key]
	end
	if key == "10" or key == "11" then
		local normal = vim.api.nvim_get_hl(0, { name = "Normal", link = false })
		return to_osc_rgb(key == "10" and normal.fg or normal.bg)
	end
	local n = key:match("^4;(%d+)$")
	return n and to_osc_rgb(vim.b["terminal_color_" .. n] or vim.g["terminal_color_" .. n])
end

local function is_opencode(buf)
	local info = vim.b[buf].snacks_terminal
	return info and info.cmd == OPENCODE_CMD
end

local function setup_colors()
	local group = vim.api.nvim_create_augroup("user_opencode_colors", { clear = true })

	vim.api.nvim_create_autocmd("TermResponse", {
		group = group,
		callback = function(ev)
			local key, color = ev.data.sequence:match("^\27%]([%d;]+);(rgb:[%x/]+)")
			if key then
				host_colors[key] = color
			end
		end,
	})
	local queries = { "\27]10;?\7", "\27]11;?\7" }
	for i = 0, 15 do
		queries[#queries + 1] = ("\27]4;%d;?\7"):format(i)
	end
	vim.api.nvim_ui_send(table.concat(queries))

	-- So that indexed colors also render like the real terminal's palette, nvim reads these during TermOpen
	vim.api.nvim_create_autocmd("TermOpen", {
		group = group,
		callback = function(ev)
			if not is_opencode(ev.buf) then
				return
			end
			for i = 0, 15 do
				local r, g, b = (host_colors["4;" .. i] or ""):match("^rgb:(%x%x)%x*/(%x%x)%x*/(%x%x)")
				if r then
					vim.b[ev.buf]["terminal_color_" .. i] = "#" .. r .. g .. b
				end
			end
		end,
	})

	-- nvim's builtin fg/bg responder would otherwise answer first, so we take it over and only defer to it for
	-- terminals that aren't opencode
	local builtin
	local ok, autocmds = pcall(vim.api.nvim_get_autocmds, { group = "nvim.terminal", event = "TermRequest" })
	for _, au in ipairs(ok and autocmds or {}) do
		if au.desc == "Handles OSC foreground/background color requests" and type(au.callback) == "function" then
			builtin = au.callback
			vim.api.nvim_del_autocmd(au.id)
		end
	end
	vim.api.nvim_create_autocmd("TermRequest", {
		group = group,
		desc = "Answer opencode's OSC color queries with the real terminal's colors",
		callback = function(ev)
			if is_opencode(ev.buf) then
				local key = ev.data.sequence:match("^\27%]([%d;]+);%?$")
				local color = key and color_for(key)
				if color then
					vim.api.nvim_chan_send(vim.bo[ev.buf].channel, ("\27]%s;%s%s"):format(key, color, ev.data.terminator))
					return
				end
			end
			if builtin then
				builtin(ev)
			end
		end,
	})
end
-- }}}

return {
	{
		"nickjvandyke/opencode.nvim",
		lazy = false,
		dependencies = { "folke/snacks.nvim" },
		-- opencode.nvim reads this when it first loads, so it has to be set before then
		init = function()
			setup_colors()

			---@type opencode.Opts
			vim.g.opencode_opts = {
				server = {
					start = function()
						Snacks.terminal.get(terminal())
					end,
				},
			}
		end,
		keys = {
			{ "<c-q>", toggle, desc = "opencode Toggle", mode = { "n", "t", "i", "x" } },
			{ "<leader>aa", toggle, desc = "opencode Toggle" },
			{
				"<leader>as",
				function()
					require("opencode").ask()
				end,
				mode = { "n", "x" },
				desc = "opencode Ask",
			},
			{
				"<leader>ad",
				function()
					local cmd, opts = terminal()
					local term = Snacks.terminal.get(cmd, vim.tbl_extend("force", opts, { create = false }))
					if term then
						term:close()
					end
				end,
				desc = "opencode Close Terminal",
			},
			{
				"<leader>at",
				function()
					require("opencode").ask("@this: ")
				end,
				mode = { "x", "n" },
				desc = "opencode Ask About This",
			},
			{
				"<leader>af",
				function()
					require("opencode").ask("@buffer: ")
				end,
				desc = "opencode Ask About File",
			},
			{
				"<leader>av",
				function()
					require("opencode").ask("@this: ")
				end,
				mode = { "x" },
				desc = "opencode Ask About Selection",
			},
			{
				"<leader>ap",
				function()
					require("opencode").select()
				end,
				mode = { "n", "x" },
				desc = "opencode Select Prompt / Command",
			},
		},
	},
	-- Gives opencode.nvim's ask() context highlighting and completion, merged into the spec in snacks.picker.lua
	{
		"folke/snacks.nvim",
		opts = {
			input = { enabled = true },
		},
	},
}

-- vim: fdm=marker ts=2 sw=2 sts=2 noet
