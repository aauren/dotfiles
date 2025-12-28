return {
	{
		'stevearc/conform.nvim',
		opts = {
		},
		keys = {
			{
				"<leader>f",
				function()
					require("conform").format()
				end,
				desc = "Format current document",
			},
		},
		config = function()
			require("conform").setup({
				default_format_opts = {
					lsp_format = "fallback",
				},
				-- formatters = {
					-- shows how to append two args to the linter call
					-- shfmt = {
					-- 	append_args = function(self, ctx)
					-- 		return { "-i", "2" }
					-- 	end,
					-- },
				-- }
				formatters_by_ft = {
					-- This section should be kept in sync with nvim.lua.plugins.lspconfig.lua (see formatters section)
					-- Conform will run multiple formatters sequentially
					-- Conform will run the first available formatter
					-- You can customize some of the format options for the filetype (:help conform.format)
					javascript = { "prettierd", "prettier", stop_after_first = true },
					json = { "jq" },
					go = { "gofmt", "goimports" },
					lua = { "stylua", "lua-format", stop_after_first = true },
					python = { "isort", "black" },
					rust = { "rustfmt", lsp_format = "fallback" },
					shell = { "shfmt" },
					terraform = { "terraform_fmt" },
					xml = { "xmllint" },
					yaml = { "yamlfmt" }
				},
				log_level = vim.log.levels.DEBUG,
			})
		end,
	}
}

-- vim: fdm=marker ts=2 sw=2 sts=2 noet
