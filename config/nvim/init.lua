vim.g.mapleader = " "
vim.g.maplocalleader = ","
require("config.options")
require("config.keymaps")
require("config.autocmds")
require("config.lazy")
require("user.commands")
require("user.sessions").setup()

require("user.productivity").setup()

require("user.workspace").setup()

require("user.windowbar").setup()
