return {
	{
		"neovim/nvim-lspconfig",
		dependencies = {
			-- Automatically install LSPs and formatters
			"mason-org/mason.nvim",
			"mason-org/mason-lspconfig.nvim",

			-- Useful status updates for LSP
			{ "j-hui/fidget.nvim", opts = {} },

			-- Autocompletion
			"hrsh7th/nvim-cmp",
			"hrsh7th/cmp-nvim-lsp",
		},
		config = function()
			local mason_lspconfig = require("mason-lspconfig")
			local mason_registry = require("mason-registry")

			mason_registry.refresh()

			-- Define the list of servers to be installed automatically by mason-lspconfig.
			-- See `:help mason-lspconfig-ensure-installed` for more details.
			local servers = {
				"ansiblels",
				"clangd",
				"cmake",
				"dockerls",
				"gh_actions_ls",
				"gitlab_ci_ls",
				"golangci_lint_ls",
				"gopls",
				"helm_ls",
				"lua_ls",
				"nginx_language_server",
				"pyright",
				"terraformls",
				"tflint",
				"yamlls",
			}

			-- Setup mason so it can manage external tools.
			require("mason").setup()

			-- Use mason-lspconfig to configure servers based on the `servers` list.
			-- This will automatically pass the `on_attach` function and capabilities to each server.
			mason_lspconfig.setup({
				ensure_installed = servers,
			})

			-- {{{ Configure golangci-lint
			vim.lsp.config('golangci_lint_ls', {
				cmd = {'golangci-lint-langserver'},
				root_markers = { '.git', 'go.mod' },
				init_options = {
					command = {
						'golangci-lint', 'run', '--output.json.path', 'stdout', '--show-stats=false', '--issues-exit-code=1'
					},
				},
			})
			-- }}}
		end,
	}
}
