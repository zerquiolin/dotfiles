return {
	{
		"nvim-treesitter/nvim-treesitter",
		branch = "main",
		lazy = false,
		build = ":TSUpdate",
		config = function()
			require("nvim-treesitter").setup({})
			vim.api.nvim_create_autocmd("FileType", {
				pattern = {
					"python",
					"javascript",
					"javascriptreact",
					"typescript",
					"typescriptreact",
					"lua",
					"tex",
					"json",
					"jsonc",
					"css",
					"html",
					"markdown",
				},
				callback = function(ev)
					if not vim.b[ev.buf].large_file then
						pcall(vim.treesitter.start, ev.buf)
					end
				end,
			})
		end,
	},
}
