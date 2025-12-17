return {
	{
		"mfussenegger/nvim-lint",
		event = "VeryLazy",
		config = function()
			local lint = require("lint")

			-- Define your linters here.
			-- nvim-lint will automatically use the executables installed by Mason.
			lint.linters_by_ft = {
				ansible = { "ansible_lint" },
				bash = { "shellcheck" },
				docker = { "hadolint" },
				go = { "golangcilint" },
				lua = { "luacheck" },
				markdown = { "markdownlint" },
				opa = { "opacheck" },
				python = { "flake8" },
				terraform = { "tflint", "tfsec" },
				yaml = { "yamllint"},
			}

			-- Create an autocommand to run the linters on save and on buffer enter.
			vim.api.nvim_create_autocmd({ "BufWritePost", "BufEnter" }, {
				callback = function()
					lint.try_lint()
				end,
			})
		end,
	}
}

-- vim: fdm=marker ts=2 sw=2 sts=2 noet
