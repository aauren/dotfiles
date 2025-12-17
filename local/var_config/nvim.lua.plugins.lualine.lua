return {
	{
		"nvim-lualine/lualine.nvim",
		dependencies = { "nvim-tree/nvim-web-devicons" },
		config = function()
			require("lualine").setup{
				sections = {
					lualine_c = {
						{
							"filename",
							path = 1,
						},
					},
				},
			}
		end,
	},
}

-- vim: fdm=marker ts=2 sw=2 sts=2 noet
