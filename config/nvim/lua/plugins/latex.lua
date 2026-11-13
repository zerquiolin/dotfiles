return {
	{
		"lervag/vimtex",
		lazy = false,
		init = function()
			-- VimTeX's filetype hooks need to be present before the first TeX buffer.
			vim.g.vimtex_view_method = "general"
			vim.g.vimtex_view_general_viewer = "open"
			vim.g.vimtex_view_general_options = "-a Preview @pdf"
			vim.g.vimtex_view_automatic = 1
			vim.g.vimtex_view_forward_search_on_start = 0
			vim.g.vimtex_compiler_method = "latexmk"
			vim.g.vimtex_quickfix_mode = 0
			vim.g.vimtex_mappings_enabled = 0
			vim.g.vimtex_syntax_enabled = 0
		end,
		keys = {
			{ "<localleader>ll", "<Cmd>VimtexCompile<CR>", desc = "Compile LaTeX" },
			{ "<localleader>lv", "<Cmd>VimtexView<CR>", desc = "View PDF" },
			{ "<localleader>lt", "<Cmd>VimtexTocOpen<CR>", desc = "LaTeX contents" },
		},
	},
}
