-- Require our functions file as our keybindings make use of that
local myfn = require("config.user.functions")

-- Set search to always highlight
vim.opt.hlsearch = true

-- Set line numbering to true
vim.opt.number = true

-- Set visual tab spacing to 4 characters instead of 8
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.softtabstop = 4

-- {{{ Initially set defaults
myfn.BaseSanity()

-- Upon buffer read or new buffer setup our listchars settings
local basesanity_group = vim.api.nvim_create_augroup("basesanity", { clear = true })

vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile", "BufWinEnter" }, {
	group = basesanity_group,
	pattern = "*",
	callback = function(ev)
		pcall(myfn.BaseSanity, ev)
	end,
	desc = "Make sure that base settings are always on",
})
-- }}}

-- {{{ Set persistent undo
-- Define the undo directory path
local undo_dir = vim.fn.expand("$HOME/.local/state/nvim/undodir/")

-- Create the directory if it doesn't exist
-- The 'p' flag creates parent directories as needed (like mkdir -p)
vim.fn.mkdir(undo_dir, "p")

-- Set the undo directory
vim.o.undodir = undo_dir

-- Enable persistent undo
vim.o.undofile = true
-- }}}

-- {{{ Whitespace Handling (including showing it on enter)

-- Setup highlights to be used in autocmds and the functions that autocmds call
vim.api.nvim_set_hl(0, "ExtraWhitespace", {
	ctermbg = "red",
	bg = "red",
})
vim.api.nvim_set_hl(0, "ExtraWhitespaceBol", {
	ctermbg = "darkgrey",
	guifg = darkgrey,
})
vim.api.nvim_set_hl(0, "ExtraWhitespacMol", {
	ctermfg = 8,
	ctermbg = 8,
})

-- Create the whitespace augroup
local whitespace_group = vim.api.nvim_create_augroup("whitespace", { clear = true })

-- When we first open VIM we need to have a rule that maches EOL whitespace (before the InsertEnter and InsertLeave
-- autocmds above are called) so that we can see whitespace before messing with insertmode
vim.fn.matchadd("ExtraWhitespace", [[\s\+$]], 10, 104)

-- Upon buffer read or new buffer setup our listchars settings
vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
	group = whitespace_group,
	pattern = "*",
	callback = function()
		myfn.SetupLCS()
	end,
	desc = "Setup listchars on buffer read or new file",
})

-- Show extra whitespace EXCEPT when typing at the end of the line
-- Load this match when entering insert mode
vim.api.nvim_create_autocmd("InsertEnter", {
	group = whitespace_group,
	pattern = "*",
	callback = function()
		pcall(vim.fn.matchadd, "ExtraWhitespace", [[\s\+\%#\@<!$]], 10, 103)
		pcall(vim.fn.matchdelete, 104)
	end,
	desc = "Show extra whitespace except at cursor position in insert mode",
})

-- Always show whitespace at the end of the line when leaving insert mode
vim.api.nvim_create_autocmd("InsertLeave", {
	group = whitespace_group,
	pattern = "*",
	callback = function()
		pcall(vim.fn.matchadd, "ExtraWhitespace", [[\s\+$]], 10, 104)
		pcall(vim.fn.matchdelete, 103)
	end,
	desc = "Show all trailing whitespace when leaving insert mode",
})
-- }}}

-- {{{ Handle Specific File Types
local filetype_group = vim.api.nvim_create_augroup("filetype", { clear = true })

-- }}}

-- {{{ Restore Last Cursor Postition in File
-- restore cursor to file position in previous editing session
-- Restore last cursor position and center view, without breaking terminal-mode
vim.api.nvim_create_autocmd("BufReadPost", {
	callback = function(args)
		-- Ignore special buffers (terminal, nofile, prompt, etc.)
		if vim.bo[args.buf].buftype ~= "" then
			return
		end

		-- If something requested a specific line, don't restore last cursor
		if vim.v.lnum > 1 then
			vim.b[args.buf].last_cursor_restore_skip = true
			return
		end

		vim.b[args.buf].last_cursor_restore_skip = false
	end,
})

vim.api.nvim_create_autocmd("BufWinEnter", {
	callback = function(args)
		-- Ignore special buffers (terminal, nofile, prompt, etc.)
		if vim.bo[args.buf].buftype ~= "" then
			return
		end

		if vim.b[args.buf].last_cursor_restore_skip then
			return
		end

		if vim.b[args.buf].last_cursor_restored then
			return
		end

		-- Defer until UI/window state is stable, but run in the correct window
		vim.schedule(function()
			if vim.api.nvim_get_current_buf() ~= args.buf then
				return
			end

			local mark = vim.api.nvim_buf_get_mark(args.buf, '"')
			local line_count = vim.api.nvim_buf_line_count(args.buf)

			-- mark = {line, col}; line=0 means "no mark"
			if mark[1] == 0 or mark[1] > line_count then
				return
			end

			pcall(vim.api.nvim_win_set_cursor, 0, mark)
			pcall(vim.cmd, "normal! zz")
			vim.b[args.buf].last_cursor_restored = true
		end)
	end,
})

-- }}}

-- {{{ Auto Resize Splits When Term Win Changes Size
-- auto resize splits when the terminal's window is resized
vim.api.nvim_create_autocmd("VimResized", {
	command = "wincmd =",
})
-- }}}

-- {{{ Highlight Other Occurrances of Word When Cursor Stops Moving
-- ide like highlight when stopping cursor
vim.api.nvim_create_autocmd("CursorMoved", {
	group = vim.api.nvim_create_augroup("LspReferenceHighlight", { clear = true }),
	desc = "Highlight references under cursor",
	callback = function()
		-- Only run if the cursor is not in insert mode
		if vim.fn.mode() ~= "i" then
			local clients = vim.lsp.get_clients({ bufnr = 0 })
			local supports_highlight = false
			for _, client in ipairs(clients) do
				if client.server_capabilities.documentHighlightProvider then
					supports_highlight = true
					break -- Found a supporting client, no need to check others
				end
			end

			-- 3. Proceed only if an LSP is active AND supports the feature
			if supports_highlight then
				vim.lsp.buf.clear_references()
				vim.lsp.buf.document_highlight()
			end
		end
	end,
})

-- ide like highlight when stopping cursor
vim.api.nvim_create_autocmd("CursorMovedI", {
	group = "LspReferenceHighlight",
	desc = "Clear highlights when entering insert mode",
	callback = function()
		vim.lsp.buf.clear_references()
	end,
})
-- }}}

-- vim: fdm=marker ts=2 sw=2 sts=2 noet
