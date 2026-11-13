return {
	{
		"saghen/blink.cmp",
		version = "1.*",
		event = "InsertEnter",
		opts = {
			keymap = {
				preset = "default",
				["<Tab>"] = { "select_next", "snippet_forward", "fallback" },
				["<S-Tab>"] = { "select_prev", "snippet_backward", "fallback" },
				["<CR>"] = { "accept", "fallback" },
			},
			completion = {
				list = { selection = { preselect = false, auto_insert = false } },
				documentation = { auto_show = false },
			},
			sources = { default = { "lsp", "path", "snippets", "buffer" } },
			fuzzy = { implementation = "prefer_rust_with_warning" },
		},
	},
	{
		"zbirenbaum/copilot.lua",
		cmd = "Copilot",
		event = "InsertEnter",
		opts = {
			panel = { enabled = false, keymap = { open = "<M-p>" } },
			suggestion = {
				enabled = true,
				auto_trigger = true,
				keymap = { accept = "<M-CR>", next = "<M-]>", prev = "<M-[>", dismiss = "<C-]>" },
			},
			filetypes = { markdown = true, tex = true, yaml = true },
			should_attach = function(buf)
				return not vim.b[buf].large_file and vim.bo[buf].buftype == ""
			end,
		},
	},
}
