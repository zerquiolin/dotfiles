local map = vim.keymap.set
for key, direction in pairs({ h = "h", j = "j", k = "k", l = "l" }) do
	map("n", "s" .. key, "<C-w>" .. direction, { desc = "Focus " .. direction })
end
map("n", "<C-h>", "<Cmd>vertical resize -3<CR>")
map("n", "<C-l>", "<Cmd>vertical resize +3<CR>")
map("n", "<C-j>", "<Cmd>resize -2<CR>")
map("n", "<C-k>", "<Cmd>resize +2<CR>")
map("n", "<leader>q", function()
	require("user.close").view()
end, { desc = "Close current view" })
map("n", "<leader>Q", "<Cmd>confirm quit<CR>", { desc = "Close window" })
map("n", "<leader>bd", function()
	require("user.close").view()
end, { desc = "Close current view" })
map("n", "<leader>tn", "<Cmd>tabnew<CR>", { desc = "New tab" })
map("n", "<leader>ss", function()
	vim.cmd.tabnew()
	vim.cmd.new()
	require("user.windows").equalize()
end, { desc = "New tab with separate horizontal buffers" })
map("n", "<leader>sv", function()
	vim.cmd.tabnew()
	vim.cmd.vnew()
	require("user.windows").equalize()
end, { desc = "New tab with separate vertical buffers" })
map("n", "tn", "<Cmd>bnext<CR>", { desc = "Next buffer" })
map("n", "tp", "<Cmd>bprevious<CR>", { desc = "Previous buffer" })
map("n", "]b", "<Cmd>bnext<CR>")
map("n", "[b", "<Cmd>bprevious<CR>")
map("n", "<Esc>", "<Cmd>nohlsearch<CR>")
map("n", "<M-J>", "<Cmd>move .+1<CR>==")
map("n", "<M-K>", "<Cmd>move .-2<CR>==")
map("x", "<M-J>", ":move '>+1<CR>gv=gv")
map("x", "<M-K>", ":move '<-2<CR>gv=gv")
map("n", "<F14>", "<Cmd>normal! yyp<CR>", { desc = "Duplicate line" })
map("x", "<F14>", '"zy`>p', { desc = "Duplicate selection" })
map("t", "<Esc><Esc>", "<C-\\><C-n>")
map({ "n", "t" }, "<F13>", function()
	require("user.terminal").toggle()
end, { desc = "Toggle terminal" })
map("n", "<leader>ot", function()
	require("user.terminal").toggle()
end, { desc = "Toggle terminal" })

map("n", "<F15>", function()
	require("nvim-tree.api").tree.toggle()
end, { desc = "Toggle explorer" })

-- Ghostty translates Cmd-/ to F16; use Neovim's native comment operator.
map("n", "<F16>", "gcc", { remap = true, desc = "Toggle line comment" })
map("x", "<F16>", "gc", { remap = true, desc = "Toggle selected comments" })
map("i", "<F16>", "<C-o>gcc", { remap = true, desc = "Toggle line comment" })

-- Ghostty translates Cmd-S to F17; save without leaving the current mode.
map({ "n", "i", "x" }, "<F17>", "<Cmd>write<CR>", { desc = "Save file" })

-- Native Ghostty Cmd-V pastes bracketed clipboard text; these are fallbacks for terminals that forward it.
map("n", "<D-v>", '"+p', { desc = "Paste system clipboard" })
map("x", "<D-v>", '"+P', { desc = "Paste system clipboard over selection" })
map("i", "<D-v>", "<C-r>+", { desc = "Paste system clipboard" })

-- Plain y stays in Vim's unnamed register; Cmd-C copies to the system clipboard.
map("n", "<D-c>", '"+yy', { desc = "Copy line to system clipboard" })
map("x", "<D-c>", '"+y', { desc = "Copy selection to system clipboard" })
map("i", "<D-c>", '<C-o>"+yy', { desc = "Copy line to system clipboard" })

-- Also accept native Command-modified keys when a terminal forwards them.
map("n", "<D-/>", "gcc", { remap = true, desc = "Toggle line comment" })
map("x", "<D-/>", "gc", { remap = true, desc = "Toggle selected comments" })
map("i", "<D-/>", "<C-o>gcc", { remap = true, desc = "Toggle line comment" })
map({ "n", "i", "x" }, "<D-s>", "<Cmd>write<CR>", { desc = "Save file" })

-- Cmd-Q closes this view rather than deleting its shared file buffer.
map({ "n", "i", "x" }, "<F18>", function()
	require("user.close").view()
end, { desc = "Close current view" })
map({ "n", "i", "x" }, "<D-q>", function()
	require("user.close").view()
end, { desc = "Close current view" })

map("n", "<leader>=", function()
	require("user.windows").equalize()
end, { desc = "Balance editor panes" })
