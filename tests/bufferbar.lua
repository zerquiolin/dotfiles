local dir = vim.fn.tempname()
vim.fn.mkdir(dir, "p")
for _, name in ipairs({ "alpha.txt", "beta.txt", "gamma.txt", "delta.txt" }) do
	vim.fn.writefile({ name }, dir .. "/" .. name)
end
vim.cmd.edit(dir .. "/alpha.txt")
vim.cmd.vsplit(dir .. "/beta.txt")
vim.cmd.split(dir .. "/gamma.txt")
vim.cmd.vsplit(dir .. "/delta.txt")
for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
	local name = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(vim.api.nvim_win_get_buf(win)), ":t")
	local text = vim.api.nvim_eval_statusline(vim.wo[win].winbar, { winid = win, use_winbar = true }).str
	assert(text:find(name, 1, true), text .. " should contain " .. name)
end
assert(vim.o.showtabline == 0)
local win = vim.api.nvim_get_current_win()
vim.api.nvim_buf_set_lines(0, 0, -1, false, { "unsaved" })
assert(vim.api.nvim_eval_statusline(vim.wo.winbar, { winid = win, use_winbar = true }).str:find("●", 1, true))
vim.bo.modified = false
local before = vim.api.nvim_get_current_buf()
vim.api.nvim_feedkeys("tp", "xt", false)
assert(vim.api.nvim_get_current_buf() ~= before)
vim.api.nvim_feedkeys("tn", "xt", false)
assert(vim.api.nvim_get_current_buf() == before)
assert(vim.o.smoothscroll and vim.o.mousescroll == "ver:3,hor:2")
print("PASS four pane-local filenames, modified marker, buffer cycling and scrolling options")
vim.cmd("qa!")
