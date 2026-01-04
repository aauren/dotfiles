return {
	{
		'nvim-telescope/telescope.nvim', branch = 'master',
		dependencies = {
			'nvim-lua/plenary.nvim',
			'smartpde/telescope-recent-files',
		},
		config = function()
			require('telescope').load_extension('recent_files')
			local builtin = require('telescope.builtin')
			local ts = require('telescope')
			vim.keymap.set('n', '<c-p>', builtin.git_files, { desc = 'Telescope find git files' })
			vim.keymap.set('n', '<A-p>', builtin.find_files, { desc = 'Telescope find files' })
			vim.keymap.set('n', '<c-t>', builtin.lsp_dynamic_workspace_symbols, { desc = 'Telescope find workspace symbols' })
			vim.keymap.set('n', '<A-r>', builtin.live_grep, { desc = 'Telescope live grep' })
			vim.keymap.set('n', '<c-b>', ts.extensions.recent_files.pick, { desc = 'Telescope buffers' })
			vim.keymap.set('n', '<leader>fh', builtin.help_tags, { desc = 'Telescope help tags' })
		end,
	}
}

-- vim: fdm=marker ts=2 sw=2 sts=2 noet
