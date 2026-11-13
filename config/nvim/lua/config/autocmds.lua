local group = vim.api.nvim_create_augroup("Dotfiles", { clear = true })
vim.api.nvim_create_autocmd("TextYankPost", {
	group = group,
	callback = function()
		vim.hl.on_yank()
	end,
})
vim.api.nvim_create_autocmd("FileType", {
	group = group,
	pattern = "python",
	callback = function()
		vim.bo.shiftwidth = 4
		vim.bo.tabstop = 4
	end,
})
vim.api.nvim_create_autocmd("BufReadPre", {
	group = group,
	callback = function(ev)
		local stat = vim.uv.fs_stat(ev.file)
		if stat and stat.size > 1024 * 1024 then
			vim.b[ev.buf].large_file = true
			vim.b[ev.buf].copilot_enabled = false
			vim.bo[ev.buf].swapfile = false
			vim.bo[ev.buf].syntax = "off"
		end
	end,
})
vim.diagnostic.config({ virtual_text = false, severity_sort = true, float = { border = "rounded" } })

require("user.windows").setup()
