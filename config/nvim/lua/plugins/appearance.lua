local c = require("user.theme").palette()
return {
	{
		"olivercederborg/poimandres.nvim",
		lazy = false,
		priority = 1000,
		dependencies = {
			"folke/tokyonight.nvim",
			{ "catppuccin/nvim", name = "catppuccin" },
			"rose-pine/neovim",
			"rebelot/kanagawa.nvim",
		},
		config = function()
			local function italicize_syntax()
				local groups = {
					"Comment",
					"@comment",
					"@comment.documentation",
					"@comment.error",
					"@comment.warning",
					"@comment.note",
					"@comment.todo",
					"@keyword",
					"@keyword.function",
					"@keyword.operator",
					"@keyword.return",
					"@keyword.conditional",
					"@keyword.repeat",
					"@keyword.import",
					"@conditional",
					"@repeat",
					"@include",
					"@exception",
				}
				for _, name in ipairs(groups) do
					local highlight = vim.api.nvim_get_hl(0, { name = name, link = false })
					highlight.italic = true
					vim.api.nvim_set_hl(0, name, highlight)
				end
			end
			vim.api.nvim_create_autocmd("ColorScheme", {
				group = vim.api.nvim_create_augroup("SyntaxItalics", { clear = true }),
				callback = italicize_syntax,
			})
			require("user.theme").apply()
			italicize_syntax()
			vim.api.nvim_set_hl(0, "StatusLine", { fg = c.fg, bg = "NONE" })
			vim.api.nvim_set_hl(0, "StatusLineNC", { fg = c.muted, bg = "NONE" })
		end,
	},
	{
		"lewis6991/gitsigns.nvim",
		event = { "BufReadPre", "BufNewFile" },
		opts = {
			current_line_blame = false,
			preview_config = { border = "rounded", style = "minimal", relative = "cursor" },
			on_attach = function(buf)
				vim.keymap.set("n", "<leader>gp", function()
					require("gitsigns").preview_hunk()
				end, { buffer = buf, desc = "Preview Git hunk" })
				vim.keymap.set("n", "<leader>gD", function()
					require("gitsigns").diffthis()
				end, { buffer = buf, desc = "Diff against Git index" })
			end,
		},
	},
}
