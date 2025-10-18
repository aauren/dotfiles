-- Require our functions file as our keybindings make use of that
local myfn = require('config.user.functions')

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
local basesanity_group = vim.api.nvim_create_augroup('basesanity', { clear = true })

vim.api.nvim_create_autocmd({ 'BufRead', 'BufNewFile', 'BufWinEnter' }, {
	group = basesanity_group,
	pattern = '*',
	callback = function()
		myfn.BaseSanity()
	end,
	desc = "Make sure that base settings are always on"
})
-- }}}

-- {{{ Set persistent undo
-- Define the undo directory path
local undo_dir = vim.fn.expand('$HOME/.local/state/nvim/undodir/')

-- Create the directory if it doesn't exist
-- The 'p' flag creates parent directories as needed (like mkdir -p)
vim.fn.mkdir(undo_dir, 'p')

-- Set the undo directory
vim.o.undodir = undo_dir

-- Enable persistent undo
vim.o.undofile = true
-- }}}

-- {{{ Whitespace Handling (including showing it on enter)

-- Setup highlights to be used in autocmds and the functions that autocmds call
vim.api.nvim_set_hl(0, 'ExtraWhitespace', {
	ctermbg = 'red',
	bg = 'red',
})
vim.api.nvim_set_hl(0, 'ExtraWhitespaceBol', {
	ctermbg = 'darkgrey',
	guifg = darkgrey,
})
vim.api.nvim_set_hl(0, 'ExtraWhitespacMol', {
	ctermfg = 8,
	ctermbg = 8,
})

-- Create the whitespace augroup
local whitespace_group = vim.api.nvim_create_augroup('whitespace', { clear = true })

-- When we first open VIM we need to have a rule that maches EOL whitespace (before the InsertEnter and InsertLeave
-- autocmds above are called) so that we can see whitespace before messing with insertmode
vim.fn.matchadd("ExtraWhitespace", [[\s\+$]], 10, 104)

-- Upon buffer read or new buffer setup our listchars settings
vim.api.nvim_create_autocmd({ 'BufRead', 'BufNewFile' }, {
	group = whitespace_group,
	pattern = '*',
	callback = function()
		myfn.SetupLCS()
	end,
	desc = "Setup listchars on buffer read or new file"
})

-- Show extra whitespace EXCEPT when typing at the end of the line
-- Load this match when entering insert mode
vim.api.nvim_create_autocmd('InsertEnter', {
	group = whitespace_group,
	pattern = '*',
	callback = function()
		pcall(vim.fn.matchadd, "ExtraWhitespace", [[\s\+\%#\@<!$]], 10, 103)
		pcall(vim.fn.matchdelete, 104)
	end,
	desc = "Show extra whitespace except at cursor position in insert mode"
})

-- Always show whitespace at the end of the line when leaving insert mode
vim.api.nvim_create_autocmd('InsertLeave', {
	group = whitespace_group,
	pattern = '*',
	callback = function()
		pcall(vim.fn.matchadd, "ExtraWhitespace", [[\s\+$]], 10, 104)
		pcall(vim.fn.matchdelete, 103)
	end,
	desc = "Show all trailing whitespace when leaving insert mode"
})
-- }}}

-- {{{ Handle Specific File Types
local filetype_group = vim.api.nvim_create_augroup('filetype', { clear = true })

-- }}}

-- vim: fdm=marker ts=2 noet
