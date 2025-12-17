return {
	{
		'romgrk/barbar.nvim',
		dependencies = {
			'nvim-tree/nvim-web-devicons',
		},
		init = function() vim.g.barbar_auto_setup = false end,
		opts = {
		},
	}
}

-- vim: fdm=marker ts=2 sw=2 sts=2 noet
