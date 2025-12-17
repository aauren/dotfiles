return {
	{
		"nvim-treesitter/nvim-treesitter",
		branch = 'main',
		lazy = false,
		build = ":TSUpdate",
		config = function()
			-- A list of parser names, or "all" (the listed parsers MUST always be installed)
			require'nvim-treesitter'.install {
					"bash",
					"cmake",
					"diff",
					"dockerfile",
					"git_config",
					"gitignore",
					"go",
					"gomod",
					"gosum",
					"gotmpl",
					"helm",
					"hjson",
					"html",
					"lua",
					"java",
					"javascript",
					"json",
					"make",
					"markdown",
					"markdown_inline",
					"nginx",
					"python",
					"terraform",
					"tmux",
					"toml",
					"vim",
					"vimdoc",
					"yaml"
			}
		end,
	}
}

-- vim: fdm=marker ts=2 sw=2 sts=2 noet
