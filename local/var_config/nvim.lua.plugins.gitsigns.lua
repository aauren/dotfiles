return {
	{
		'lewis6991/gitsigns.nvim',
		dependencies = {},
		-- Disable lazy mode if you find a git directory in the current working directory or above
		lazy = false,
		opts = {
		},
		keys = {
			{
				"<leader>hs",
				function()
					require("gitsigns").stage_hunk()
				end,
				desc = "Git stage hunk",
			},
			{
				"<leader>hr",
				function()
					require("gitsigns").reset_hunk()
				end,
				desc = "Git reset hunk",
			},
			{
				"<leader>hp",
				function()
					require("gitsigns").preview_hunk()
				end,
				desc = "Git preview hunk",
			},
			{
				"<leader>hi",
				function()
					require("gitsigns").preview_hunk_inline()
				end,
				desc = "Git preview hunk (inline)",
			},
			{
				"<leader>hd",
				function()
					require("gitsigns").diffthis()
				end,
				desc = "Git diff this",
			},
			{
				"<leader>hq",
				function()
					require("gitsigns").setqflist()
				end,
				desc = "Git show changes in QF list",
			},
			{
				"<leader>hb",
				function()
					require("gitsigns").toggle_current_line_blame()
				end,
				desc = "Git toggle current line blame",
			},
		},
	}
}

-- vim: fdm=marker ts=2 sw=2 sts=2 noet
