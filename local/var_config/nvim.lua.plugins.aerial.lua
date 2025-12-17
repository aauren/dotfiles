return {
	"stevearc/aerial.nvim",
	opts = {
		on_attach = function(bufnr)
			vim.keymap.set("n", "{", "<cmd>AerialPrev<CR>", { buffer = bufnr })
			vim.keymap.set("n", "}", "<cmd>AerialNext<CR>", { buffer = bufnr })
		end,
		layout = {
			resize_to_content = true,
			max_width = { 0.4 },
		},
	},
	-- Optional dependencies
	dependencies = {
		"nvim-treesitter/nvim-treesitter",
		"nvim-tree/nvim-web-devicons",
	},
	keys = {
		{
			"<leader>a",
			"<cmd>AerialToggle<cr>",
			desc = "Toggle Aerial interface",
		},
	},
}

-- vim: fdm=marker ts=2 sw=2 sts=2 noet
