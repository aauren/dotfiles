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
			local mason_core = require("mason")
			local mason_pkg = require("mason-core.package")
			local mason_registry = require("mason-registry")
			mason_registry.refresh()

			-- Unfortunately Mason does come with an ensure_installed for packages similar to how mason-lspconfig does
			-- for language servers. So we have to write this ourselves.
			-- See: https://github.com/mason-org/mason.nvim/pull/1949#pullrequestreview-2853679405 for more details
			---@param pkgs string[]
			local function mason_install(pkgs)
				local Command = require "mason.api.command"
				local pkgs_to_install = {}
				for _, pkg_identifier in ipairs(pkgs or {}) do
					local pkg_name, _ = mason_pkg.Parse(pkg_identifier)
					local ok, pkg = pcall(mason_registry.get_package, pkg_name)
					if ok and not pkg:is_installed() and not pkg:is_installing() then
						table.insert(pkgs_to_install, pkg_identifier)
					end
				end
				if not vim.tbl_isempty(pkgs_to_install) then
					Command.MasonInstall(pkgs_to_install)
				end
			end

			-- Define the list of servers to be installed automatically by mason-lspconfig.
			-- See `:help mason-lspconfig-ensure-installed` for more details.
			local lsp_servers = {
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

			local lint_servers = {
				"ansible-lint",
				"flake8",
				"golangci-int",
				"hadolint",
				"luacheck",
				"markdownlint",
				"opa",
				"shellcheck",
				"tflint",
				"tfsec",
				"yamllint",
			}

			-- Setup mason so it can manage external tools.
			mason_core.setup()

			-- Install non-lsp packages using Mason
			mason_install(lint_servers)

			-- Use mason-lspconfig to configure servers based on the `servers` list.
			-- This will automatically pass the `on_attach` function and capabilities to each server.
			mason_lspconfig.setup({
				ensure_installed = lsp_servers,
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
