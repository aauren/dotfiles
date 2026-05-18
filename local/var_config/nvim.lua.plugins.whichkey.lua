return {
	{
		"folke/which-key.nvim",
		event = "VeryLazy",
		opts = {
			-- your configuration comes here
			-- or leave it empty to use the default settings
			-- refer to the configuration section below
		},
		keys = {
			{
				"<leader>?",
				function()
					require("which-key").show({ global = false })
				end,
				desc = "Buffer Local Keymaps (which-key)",
			},
		},
		config = function(_, opts)
			local wk = require("which-key")
			wk.setup(opts)

			-- Register prefix groups so the which-key popup shows a labelled
			-- category when you press <leader>X and pause.
			--
			-- Note: several of these prefixes also have a single-key mapping
			-- (e.g. <leader>a toggles Aerial AND is the Sidekick prefix). That
			-- still works -- which-key shows both the leaf action and the
			-- sub-menu when the popup opens.
			wk.add({
				{ "<leader>a", group = "AI / Aerial" },         -- sidekick.* + aerial toggle
				{ "<leader>c", group = "code (Trouble)" },      -- <leader>cs, <leader>cl
				{ "<leader>d", group = "debug / delete" },      -- dap.* + delete-without-yank
				{ "<leader>f", group = "find / format" },       -- snacks pickers + conform format
				{ "<leader>h", group = "git hunks" },           -- gitsigns
				{ "<leader>l", group = "list toggle" },         -- <leader>li
				{ "<leader>p", group = "paste" },               -- <leader>po, <leader>pO
				{ "<leader>r", group = "resize / relnum" },     -- <leader>rv, <leader>rh + relnum toggle
				{ "<leader>t", group = "test (neotest)" },      -- <leader>t*
				{ "<leader>w", group = "window / textwidth" },  -- <leader>ws, <leader>wv + textwidth toggle
				{ "<leader>x", group = "trouble / delchar" },   -- trouble.* + delete char
			})
		end,
	},
}

-- vim: fdm=marker ts=2 sw=2 sts=2 noet
