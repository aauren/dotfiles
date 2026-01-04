-- Require our functions file as our keybindings make use of that
local myfn = require('config.user.functions')

-- {{{ Global Key Bindings

-- Remap leader key to space
vim.g.mapleader = ' '

-- }}}

--local wk = require("which-key")
--wk.add({
--	{'<A>j', 'bprevious<CR>', desc = 'Previous Buffer', group = 'buffer'},
--	{'<A>k', 'bnext<CR>', desc = 'Next Buffer', group = 'buffer'},
--})

-- {{{ Command Key Bindings

vim.keymap.set('c', 'w!!', 'w !sudo tee > /dev/null %', {
	noremap = true,
	silent = true,
	desc = 'Save file with sudo'
})

-- Cmdline completion: select next item with Down arrow
vim.keymap.set('c', '<Down>', function()
	if vim.fn.pumvisible() == 1 then
		return '<C-n>'
	end
	return '<Down>'
end, {
	noremap = true,
	expr = true,
	desc = "Cmdline completion: select next item with Down arrow"
})

-- Cmdline completion: select previous item with Up arrow
vim.keymap.set('c', '<Up>', function()
	if vim.fn.pumvisible() == 1 then
		return '<C-p>'
	end
	return '<Up>'
end, {
	noremap = true,
	expr = true,
	desc = "Cmdline completion: select previous item with Up arrow"
})

-- Allow CTRL-w to work even when terminal mode is active
vim.keymap.set('t', '<C-w>', '<C-\\><C-n><C-w>', { noremap = true, silent = true })


-- }}}

-- {{{ Visual Key Bindings

vim.keymap.set('v', 'p', myfn.repl, {
	noremap = true,
	silent = true,
	expr = true,
	desc = "Paste without replacing copy buffer"
})

vim.keymap.set('v', 'y', 'y`]', {
  noremap = true,
  silent = true,
  desc = "Yank and move cursor to end of selection"
})

vim.keymap.set('v', 'p', 'p`]', {
  noremap = true,
  silent = true,
  desc = "Paste and move cursor to end of selection"
})

vim.keymap.set('v', '<leader>d', '"_d', {
	noremap = true,
	silent = true,
	desc = "Delete without yanking"
})

-- }}}

-- {{{ Insert Key Bindings

-- Map jj & JJ to escape to leave insert mode
vim.keymap.set('i', 'jj', '<Esc>', {
	noremap = true,
	silent = true,
	desc = "Exit insert mode"
})

vim.keymap.set('i', 'JJ', '<Esc>', {
	noremap = true,
	silent = true,
	desc = "Exit insert mode"
})

-- Completion: select next item with Down arrow
vim.keymap.set('i', '<Down>', function()
	if vim.fn.pumvisible() == 1 then
		return '<C-n>'
	end
	return '<Down>'
end, {
  noremap = true,
  silent = true,
  expr = true,
  desc = "Completion: select next item with Down arrow"
})

-- Completion: select previous item with Up arrow
vim.keymap.set('i', '<Up>', function()
	if vim.fn.pumvisible() == 1 then
		return '<C-p>'
	end
	return '<Up>'
end, {
	noremap = true,
	silent = true,
	expr = true,
	desc = "Completion: select previous item with Up arrow"
})

-- }}}

-- {{{ Normal Key Bindings

-- Go to the previous buffer (using commands from plugin barbar)
vim.keymap.set('n', '<A-j>', ':BufferPrevious<CR>', {
	noremap = true,
	silent = true,
	desc = "Go to previous buffer"
})

-- Go to the next buffer (using commands from plugin barbar)
vim.keymap.set('n', '<A-k>', ':BufferNext<CR>', {
	noremap = true,
	silent = true,
	desc = "Go to next buffer"
})

-- Go to the previous tab
vim.keymap.set('n', '<A-h>', ':tabprevious<CR>', {
	noremap = true,
	silent = true,
	desc = "Go to previous tab"
})

-- Go to the next tab
vim.keymap.set('n', '<A-l>', ':tabnext<CR>', {
	noremap = true,
	silent = true,
	desc = "Go to next tab"
})

vim.keymap.set('n', 'p', 'p`]', {
	noremap = true,
	silent = true,
	desc = "Paste and move cursor to end of pasted text"
})

-- {{{ Mode Agnostic Movement using G/F/J/K
-- Move right one word in normal, visual, select, and operator-pending modes
vim.keymap.set('', '<C-G>', '<C-Right>', {
	noremap = true,
	silent = true,
	desc = "Move right one word"
})

-- Move right one word in insert and command-line modes
vim.keymap.set('!', '<C-G>', '<C-Right>', {
	noremap = true,
	silent = true,
	desc = "Move right one word"
})

-- Move left one word in normal, visual, select, and operator-pending modes
vim.keymap.set('', '<C-F>', '<C-Left>', {
	noremap = true,
	silent = true,
	desc = "Move left one word"
})

-- Move left one word in insert and command-line modes
vim.keymap.set('!', '<C-F>', '<C-Left>', {
	noremap = true,
	silent = true,
	desc = "Move left one word"
})

-- Move to beginning of line in normal, visual, select, and operator-pending modes
vim.keymap.set('', '<C-J>', '^', {
	noremap = true,
	silent = true,
	desc = "Move to the beginning of the line"
})

-- Move to beginning of line in insert and command-line modes
vim.keymap.set('!', '<C-J>', '<Home>', {
	noremap = true,
	silent = true,
	desc = "Move to the beginning of the line"
})

-- Move to end of line in normal, visual, select, and operator-pending modes
vim.keymap.set('', '<C-K>', '$', {
	noremap = true,
	silent = true,
	desc = "Move to the end of the line"
})

-- Move to end of line in insert and command-line modes
vim.keymap.set('!', '<C-K>', '<End>', {
	noremap = true,
	silent = true,
	desc = "Move to the end of the line"
})
-- }}}

-- {{{ Mode Agnostic Movement using G/F/J/K
-- Go to the previous error location
vim.keymap.set('', '<C-n>', vim.diagnostic.goto_prev, {
	noremap = true,
	silent = true,
	desc = "Go to the previous error location"
})

-- Go to the next error location
vim.keymap.set('', '<C-m>', vim.diagnostic.goto_next, {
	noremap = true,
	silent = true,
	desc = "Go to the next error location"
})
-- }}}

-- }}}

-- {{{ Normal Leader-Based Key Bindings

-- {{{ Remap LSP code movements

vim.keymap.set('n', 'ga', vim.lsp.buf.code_action, {
	noremap = true,
	silent = true,
	desc = "Execute a code action"
})

vim.keymap.set('n', 'gd', "<cmd>Trouble lsp_definitions<cr>", {
	noremap = true,
	silent = true,
	desc = "Go to symbol definition"
})

vim.keymap.set('n', 'gr', "<cmd>Trouble lsp_references<cr>", {
	noremap = true,
	silent = true,
	desc = "Go to symbol references"
})

vim.keymap.set('n', 'gi', "<cmd>Trouble lsp_implementations<cr>", {
	noremap = true,
	silent = true,
	desc = "Go to symbol implementation"
})

vim.keymap.set('i', '<C-t>', vim.lsp.buf.signature_help, {
	noremap = true,
	desc = "Signature help"
})

-- Enable tab completion
vim.keymap.set('i', '<Tab>', function()
  if vim.fn.pumvisible() == 1 then
    -- If completion menu is visible, navigate down
    return '<C-n>'
  elseif vim.fn.col('.') > 1 and vim.fn.getline('.'):sub(vim.fn.col('.') - 1, vim.fn.col('.') - 1):match('%S') then
    -- If there's a non-whitespace character before cursor, trigger omnifunc
    return '<C-x><C-o>'
  else
    -- Otherwise, insert a tab
    return '<Tab>'
  end
end, { expr = true, noremap = true })

vim.keymap.set('i', '<S-Tab>', function()
  if vim.fn.pumvisible() == 1 then
    return '<C-p>'
  else
    return '<S-Tab>'
  end
end, { expr = true, noremap = true })

-- Ensure that enter selects the completion option instead of putting an actual carriage return in the code file
vim.keymap.set('i', '<CR>', function()
  if vim.fn.pumvisible() == 1 then
    return '<C-y>'
  else
    return '<CR>'
  end
end, { expr = true, noremap = true })

-- }}}

-- {{{ Close Buffer/Window
vim.keymap.set('n', '<leader>z', ':bdelete<CR>', {
	noremap = true,
	silent = true,
	desc = "Close current buffer"
})

vim.keymap.set('n', '<leader>Z', ':close<CR>', {
	noremap = true,
	silent = true,
	desc = "Close current window"
})
-- }}}

-- {{{ Resize vim Windows Vertically / Horizontally
-- Use a count before the mapping, e.g. 35<leader>rv
vim.keymap.set('n', '<leader>rv', function()
  local n = vim.v.count
  if n == 0 then
    -- optional: prompt if no count given
    local s = vim.fn.input('Width (percent): ')
    n = tonumber(s) or 0
  end
  if n > 0 then
    vim.cmd('vertical resize ' .. math.floor(vim.o.columns * n / 100))
  end
end, {desc = 'Vertical resize to count or prompt'})

vim.keymap.set('n', '<leader>rh', function()
  local n = vim.v.count
  if n == 0 then
    -- optional: prompt if no count given
    local s = vim.fn.input('Height (percent): ')
    n = tonumber(s) or 0
  end
  if n > 0 then
    vim.cmd('horizontal resize ' .. math.floor(vim.o.lines * n / 100))
  end
end, {desc = 'Vertical resize to count or prompt'})
-- }}}

-- {{{ Delete / Modify without Affecting Paste Buffer
vim.keymap.set('', '<leader>dd', '"_dd', {
	noremap = true,
	silent = true,
	desc = "Delete line without yanking"
})

vim.keymap.set('n', '<leader>d', '"_d', {
	noremap = true,
	silent = true,
	desc = "Delete without yanking"
})

vim.keymap.set('n', '<leader>x', '"_x', {
	noremap = true,
	silent = true,
	desc = "Delete character without yanking"
})
-- }}}

vim.keymap.set('n', '<leader>b', ':ls<CR>:b<Space>', {
	noremap = true,
	silent = false,
	desc = "List buffers and prompt to switch"
})

vim.keymap.set('n', '<leader>s', ':ToggleLeadingSpaces<CR>', {
	noremap = true,
	silent = true,
	desc = "Toggle leading spaces visibility"
})

-- Paste a partial yank on the line below
vim.keymap.set('', '<leader>po', ':pu<CR>', {
	noremap = true,
	silent = true,
	desc = "Paste a partial yank on the line below"
})

-- Paste a partial yank on the line above
vim.keymap.set('', '<leader>pO', ':pu!<CR>', {
	noremap = true,
	silent = true,
	desc = "Paste a partial yank on the line above"
})

-- Toggle to a mode that allows for copy/paste
vim.keymap.set('', '<leader>y', myfn.ToggleCopyable, {
	noremap = true,
	silent = true,
	desc = "Toggle copy mode on and off"
})

-- Toggle text width on and off
vim.keymap.set('', '<leader>w', myfn.MyTogTW, {
	noremap = true,
	silent = true,
	desc = "Toggle text width on and off"
})

-- Toggle list
vim.keymap.set('', '<leader>li', function()
	vim.o.list = not vim.o.list
end, {
	noremap = true,
	silent = true,
	desc = "Toggle showing certain whitespace characters"
})

-- Toggle number
vim.keymap.set('', '<leader>n', function()
	vim.o.number = not vim.o.number
end, {
	noremap = true,
	silent = true,
	desc = "Toggle show number"
})

-- Toggle relative line numbering
vim.keymap.set('', '<leader>r', function()
	vim.o.relativenumber = not vim.o.relativenumber
end, {
	noremap = true,
	silent = true,
	desc = "Toggle relative line numbering"
})

-- Split the current buffer to the other vertical
vim.keymap.set('', '<leader>vs', myfn.VSplitCurrentBuffer, {
	noremap = true,
	silent = true,
	desc = "Split the current buffer to the other vertical"
})

-- Split the current buffer to the other horizontal
vim.keymap.set('', '<leader>hs', myfn.SplitCurrentBuffer, {
	noremap = true,
	silent = true,
	desc = "Split the current buffer to the other horizontal"
})


-- }}}

-- vim: fdm=marker ts=2 sw=2 sts=2 noet
