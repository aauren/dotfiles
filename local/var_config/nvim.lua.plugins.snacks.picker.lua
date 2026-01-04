return {
	{
		"folke/snacks.nvim",
		priority = 1000,
		lazy = false,

		---@type snacks.Config
		opts = {
			picker = {
				enabled = true,
				-- Optional: make hidden files the default everywhere (you can still toggle)
				sources = {
					files = { hidden = true },
					grep = { hidden = true },
				},
			},
		},

		config = function(_, opts)
			-- snacks.nvim setup entrypoint (common in real configs)
			require("snacks").setup(opts)

			-- Find git root by walking upward for ".git".
			-- Returns: (root_dir, is_git)
			local function project_root()
				local buf = vim.api.nvim_buf_get_name(0)
				local start = (buf ~= "" and vim.fs.dirname(buf)) or vim.loop.cwd()

				local git = vim.fs.find(".git", { path = start, upward = true })[1]
				if git then
					return vim.fs.dirname(git), true
				end
				return start, false
			end

			-- <C-p>: project files (git root if present; otherwise current dir)
			local function project_files()
				local root, is_git = project_root()
				Snacks.picker.files({
					cwd = root, -- picker cwd
					hidden = true, -- show dotfiles
					ignored = not is_git, -- if git repo: respect .gitignore; else: show everything
				})
			end

			-- <A-r>: project live grep (rg) rooted like project_files
			local function project_grep()
				local root, is_git = project_root()
				Snacks.picker.grep({
					cwd = root,
					dirs = { root }, -- explicitly scope grep
					hidden = true,
					ignored = not is_git, -- respect .gitignore when in a repo
					live = true, -- Snacks grep is live by default anyway
				})
			end

			-- Keymaps
			vim.keymap.set("n", "<c-p>", project_files, { desc = "Snacks: find project files (git root)" })
			vim.keymap.set("n", "<c-t>", Snacks.picker.lsp_workspace_symbols, { desc = "Snacks: workspace symbols" })
			vim.keymap.set("n", "<A-r>", project_grep, { desc = "Snacks: live grep (git root)" })
			vim.keymap.set("n", "<c-b>", Snacks.picker.recent, { desc = "Snacks: recent files" })
			vim.keymap.set("n", "<leader>fh", Snacks.picker.help, { desc = "Snacks: help tags" })
		end,
	},
}

-- vim: fdm=marker ts=2 sw=2 sts=2 noet
