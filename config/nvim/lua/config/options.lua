vim.opt.termguicolors = true
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.signcolumn = "yes"
vim.opt.cursorline = true
vim.opt.wrap = false
vim.opt.splitright = true
vim.opt.splitbelow = true
vim.opt.equalalways = true
vim.opt.eadirection = "both"
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.updatetime = 250
vim.opt.timeoutlen = 400
vim.opt.clipboard = ""
vim.opt.undofile = true
vim.opt.expandtab = true
vim.opt.shiftwidth = 2
vim.opt.tabstop = 2
vim.opt.scrolloff = 3
vim.opt.smoothscroll = true
vim.opt.mousescroll = "ver:3,hor:2"
vim.opt.synmaxcol = 240
vim.opt.laststatus = 3
vim.opt.showmode = false
vim.opt.showtabline = 0
vim.opt.fillchars:append({ eob = " " })
vim.opt.sessionoptions:remove("terminal")
vim.opt.completeopt = { "menu", "menuone", "noselect" }
vim.opt.statusline = " %f %m%r%=%y  %l:%c "
-- Resolve the repository through symlinks, independent of the launching shell.
local config = vim.uv.fs_realpath(vim.fn.stdpath("config"))
local root = vim.fs.dirname(vim.fs.dirname(config))
vim.env.PATH = root
	.. "/.tools/node/node_modules/.bin:"
	.. root
	.. "/.tools/python/bin:/Library/TeX/texbin:"
	.. vim.env.PATH
vim.g.dotfiles_root = root
