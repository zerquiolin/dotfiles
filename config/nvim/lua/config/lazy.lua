local path = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.uv.fs_stat(path) then
	local out = vim.fn.system({
		"git",
		"clone",
		"--filter=blob:none",
		"--branch=stable",
		"https://github.com/folke/lazy.nvim.git",
		path,
	})
	if vim.v.shell_error ~= 0 then
		error("lazy.nvim bootstrap failed: " .. out)
	end
	local lock = vim.fn.json_decode(table.concat(vim.fn.readfile(vim.fn.stdpath("config") .. "/lazy-lock.json"), "\n"))
	local pinned = lock["lazy.nvim"].commit
	local checkout = vim.fn.system({ "git", "-C", path, "checkout", pinned })
	if vim.v.shell_error ~= 0 then
		error("lazy.nvim pin failed: " .. checkout)
	end
end
vim.opt.rtp:prepend(path)
require("lazy").setup("plugins", {
	change_detection = { notify = false },
	checker = { enabled = false },
	install = { colorscheme = { "poimandres" } },
})
