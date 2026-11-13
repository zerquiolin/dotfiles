return {
	{
		"kdheepak/lazygit.nvim",
		cmd = "LazyGit",
		keys = { { "<leader>gg", "<Cmd>LazyGit<CR>", desc = "Git" } },
		init = function()
			vim.g.lazygit_floating_window_scaling_factor = 0.94
			vim.g.lazygit_floating_window_winblend = 0
			vim.g.lazygit_use_custom_config_file_path = 1
			local existing = vim.trim(vim.fn.system({ "lazygit", "--print-config-dir" })) .. "/config.yml"
			local configs = {}
			if vim.fn.filereadable(existing) == 1 then
				table.insert(configs, existing)
			end
			table.insert(configs, vim.g.dotfiles_root .. "/config/lazygit/config.yml")
			vim.g.lazygit_config_file_path = configs
		end,
	},
}
