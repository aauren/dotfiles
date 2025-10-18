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

-- }}}

-- {{{ Normal Key Bindings

-- Go to the previous buffer
vim.keymap.set('n', '<A-j>', ':bprevious<CR>', {
	noremap = true,
	silent = true,
	desc = "Go to previous buffer"
})

-- Go to the next buffer
vim.keymap.set('n', '<A-k>', ':bnext<CR>', {
	noremap = true,
	silent = true,
	desc = "Go to next buffer"
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

vim.keymap.set('n', 'gd', vim.lsp.buf.definition, {
	noremap = true,
	silent = true,
	desc = "Go to symbol definition"
})

vim.keymap.set('n', 'gr', vim.lsp.buf.references, {
	noremap = true,
	silent = true,
	desc = "Go to symbol references"
})

vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, {
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

-- vim: fdm=marker ts=2 noet
