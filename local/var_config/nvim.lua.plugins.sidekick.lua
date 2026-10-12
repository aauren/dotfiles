return {
	"folke/sidekick.nvim",
	-- Disable lazy mode if you find a git directory in the current working directory or above
	lazy = false,
	opts = {
		-- add any options here
		cli = {
			mux = {
				backend = "tmux",
				enabled = true,
			},
			win = {
				split = {
					width = 0.5,
				},
				-- The review tab (see config/user/review.lua) wants its own opencode in a full-width bottom split
				config = function(terminal)
					if terminal.tool.name == "opencode_review" then
						terminal.opts.layout = "bottom"
						terminal.opts.split = { width = 0, height = 0.2, win = -1 }
					end
				end,
			},
			tools = {
				-- Same as the builtin opencode, but under a different name so that it gets its own session
				opencode_review = {
					cmd = { "opencode" },
					env = { OPENCODE_THEME = "system" },
					-- We don't want this tool claiming the regular opencode processes
					is_proc = function()
						return false
					end,
					native_scroll = true,
				},
			},
		},
	},
	keys = {
		{
			"<tab>",
			function()
				-- if there is a next edit, jump to it, otherwise apply it if any
				if not require("sidekick").nes_jump_or_apply() then
					return "<Tab>" -- fallback to normal tab
				end
			end,
			expr = true,
			desc = "Goto/Apply Next Edit Suggestion",
		},
		{
			"<c-q>",
			function()
				require("sidekick.cli").toggle(require("config.user.review").sidekick_filter())
			end,
			desc = "Sidekick Toggle",
			mode = { "n", "t", "i", "x" },
		},
		{
			"<leader>aa",
			function()
				require("sidekick.cli").toggle(require("config.user.review").sidekick_filter())
			end,
			desc = "Sidekick Toggle CLI",
		},
		{
			"<leader>as",
			function()
				require("sidekick.cli").select()
			end,
			-- Or to select only installed tools:
			-- require("sidekick.cli").select({ filter = { installed = true } })
			desc = "Select CLI",
		},
		{
			"<leader>ad",
			function()
				require("sidekick.cli").close()
			end,
			desc = "Detach a CLI Session",
		},
		{
			"<leader>at",
			function()
				require("sidekick.cli").send({ msg = "{this}" })
			end,
			mode = { "x", "n" },
			desc = "Send This",
		},
		{
			"<leader>af",
			function()
				require("sidekick.cli").send({ msg = "{file}" })
			end,
			desc = "Send File",
		},
		{
			"<leader>av",
			function()
				require("sidekick.cli").send({ msg = "{selection}" })
			end,
			mode = { "x" },
			desc = "Send Visual Selection",
		},
		{
			"<leader>ap",
			function()
				require("sidekick.cli").prompt()
			end,
			mode = { "n", "x" },
			desc = "Sidekick Select Prompt",
		},
	},
}

-- vim: fdm=marker ts=2 sw=2 sts=2 noet
