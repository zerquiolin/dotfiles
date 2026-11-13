local function web(buf)
	local filename = vim.api.nvim_buf_get_name(buf)
	local biome = vim.fs.root(filename, { "biome.json", "biome.jsonc" })
	if biome then
		return { "biome" }
	end
	return { "prettier" }
end
return {
	{
		"stevearc/conform.nvim",
		event = { "BufReadPre", "BufNewFile" },
		cmd = "ConformInfo",
		opts = {
			formatters = {
				company_latexindent = {
					command = function()
						return vim.g.dotfiles_root .. "/bin/latex-format"
					end,
					args = { "$FILENAME" },
					stdin = true,
				},
			},
			formatters_by_ft = {
				python = { "ruff_format" },
				lua = { "stylua" },
				tex = { "company_latexindent" },
				javascript = web,
				javascriptreact = web,
				typescript = web,
				typescriptreact = web,
				json = web,
				jsonc = web,
				css = { "prettier" },
				html = { "prettier" },
				markdown = { "prettier" },
				yaml = { "prettier" },
			},
			default_format_opts = { lsp_format = "never" },
			format_after_save = function(buf)
				if vim.b[buf].disable_autoformat or vim.b[buf].large_file then
					return
				end
				return { lsp_format = "never" }
			end,
		},
	},
}
