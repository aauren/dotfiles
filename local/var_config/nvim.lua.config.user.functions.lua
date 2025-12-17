local M = {}

-- {{{ Default Sanity Functions That Run on BuffEnter
function M.BaseSanity(ev)
	local DEFAULT_TW = 120

	-- Disable mouse mode so that I can use the mouse to highlight things and the like
	vim.opt.mouse = ""

	-- Allows you to open a new buffer when there are unwritten changes to the current buffer
	vim.opt.hidden = true

	-- Set magic to default on
	vim.opt.magic = true

	-- Set Text Width to 120 chars
	---- If EditorConfig or modeline set a value, it won't be 0, so we leave it alone.
	if ev == nil then
		vim.opt.textwidth = DEFAULT_TW
	elseif vim.bo[ev.buf].textwidth == 0 then
		vim.bo[ev.buf].textwidth = DEFAULT_TW
	end

	-- Set marker at the text width
	vim.opt.colorcolumn = '+1'

	-- Auto wrap at the textwidth
	vim.opt.formatoptions:append('t')
end
-- }}}

-- {{{ Paste without replacing the paste buffer
-- Store the original register content

local restore_reg = nil

local function restore_register()
	vim.fn.setreg('"', restore_reg)
	return ''
end

function M.repl()
	restore_reg = vim.fn.getreg('"')
	return 'p@=v:lua.restore_register()<CR>'
end

-- Make restore_register globally accessible
_G.restore_register = restore_register
-- }}}

-- {{{ Toggle Leading Spaces
-- Initialize the global variable if it doesn't exist
if vim.g.show_leading_space == nil then
	vim.g.show_leading_space = 0
end

-- Define the SetupLCS function
function M.SetupLCS()
	vim.opt.list = true
	vim.opt.listchars = {
		tab = '|->',
		nbsp = '·',
		trail = '·',
		extends = '>',
		precedes = '<'
	}
end

vim.api.nvim_create_user_command('SetupLCS', function()
	M.SetupLCS()
end, {
	desc = "Enable visualize leading spaces"
})

-- Define the ToggleLeadingSpaces function
function M.toggle_leading_spaces(no_toggle)
	-- Toggle the setting unless no_toggle is true
	if not no_toggle then
		if vim.g.show_leading_space == 0 then
			vim.g.show_leading_space = 1
		else
			vim.g.show_leading_space = 0
		end
	end

	if vim.g.show_leading_space == 1 then
		-- Show leading spaces
		-- Call SetupLCS() - you'll need to convert this function too
		M.SetupLCS()

		-- Show the space character as a ·
		vim.opt.listchars:append({ space = '·' })

		-- Match all whitespace and hide it
		vim.fn.matchadd("WhiteSpaceMol", " ", 11, 100)

		-- Override for leading spaces to show them
		vim.fn.matchadd("WhiteSpaceBol", [[^ \+]], 11, 101)
	else
		-- Hide leading spaces
		M.SetupLCS()

		-- Delete the matches
		pcall(vim.fn.matchdelete, 100)
		pcall(vim.fn.matchdelete, 101)
	end
end

-- Create the user command
vim.api.nvim_create_user_command('ToggleLeadingSpaces', function()
	M.toggle_leading_spaces(false)
end, {
	desc = "Toggle leading spaces visibility for easier copy/paste"
})

-- }}}

-- {{{ Toggle Copyable
-- Initialize state variable for ToggleCopyable
vim.g.copyable_mode = false

-- Store textwidth and wrapmargin values
vim.g.saved_textwidth = vim.o.textwidth
vim.g.saved_wrapmargin = vim.o.wrapmargin
vim.g.saved_relative_num = vim.o.relativenumber
vim.g.saved_num = vim.o.number

-- MyTogTW function
function M.MyTogTW()
	if vim.o.textwidth ~= 0 then
		-- Save current values and disable
		vim.g.saved_textwidth = vim.o.textwidth
		vim.g.saved_wrapmargin = vim.o.wrapmargin
		vim.opt.textwidth = 0
		vim.opt.wrapmargin = 0
		vim.opt.colorcolumn = '0'
	else
		-- Restore saved values
		vim.opt.textwidth = vim.g.saved_textwidth
		vim.opt.wrapmargin = vim.g.saved_wrapmargin
		vim.opt.colorcolumn = '+1'
	end
end

-- ToggleCopyable function with state-based toggling
function M.ToggleCopyable()
	local gs = require('gitsigns')
	local indent = require('blink.indent')

	if vim.g.copyable_mode then
		-- Turn everything back on
		vim.o.list = true
		vim.o.number = vim.g.saved_num
		vim.o.relativenumber = vim.g.saved_relative_num
		vim.g.copyable_mode = false
		vim.diagnostic.show()
		gs.toggle_signs(true)
		indent.enable(true)
	else
		-- Turn everything off for easy copying
		vim.g.saved_relative_num = vim.o.relativenumber
		vim.g.saved_num = vim.o.number
		vim.o.list = false
		vim.o.number = false
		vim.o.relativenumber = false
		vim.g.copyable_mode = true
		vim.diagnostic.hide()
		gs.toggle_signs(false)
		indent.enable(false)
	end

	M.MyTogTW()
end

-- }}}

-- {{{ Buffer split functions

-- Split the current buffer vertically and rotate main screen to previous buffer
function M.VSplitCurrentBuffer()
	vim.cmd('vsplit')
	vim.cmd('wincmd h')
	vim.cmd('bprevious')
end

-- Split the current buffer horizontally and rotate main screen to previous buffer
function M.SplitCurrentBuffer()
	vim.cmd('split')
	vim.cmd('wincmd k')
	vim.cmd('bprevious')
end

-- }}}

return M

-- vim: fdm=marker ts=2 sw=2 sts=2 noet
