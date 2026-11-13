local function keys(s)
	vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(s, true, false, true), "xt", false)
end
vim.cmd.enew()
local shared = vim.api.nvim_get_current_buf()
vim.api.nvim_buf_set_lines(shared, 0, -1, false, { "unsaved shared text" })
vim.cmd.vsplit()
local original = vim.api.nvim_list_wins()[1]
keys("<F18>")
assert(#vim.api.nvim_tabpage_list_wins(0) == 1, "Close must remove exactly one split")
assert(vim.api.nvim_buf_is_valid(shared) and vim.api.nvim_get_current_buf() == shared, "Other shared view must remain")
assert(vim.bo[shared].modified, "Unsaved shared content must remain modified")
vim.cmd("tab split")
local count = #vim.api.nvim_list_tabpages()
keys("<D-q>")
assert(#vim.api.nvim_list_tabpages() == count - 1, "Close must remove just this tab")
assert(vim.api.nvim_get_current_buf() == shared, "Other tab must still display shared file")
assert(vim.api.nvim_buf_get_lines(shared, 0, 1, false)[1] == "unsaved shared text")
local confirm = vim.fn.confirm
vim.fn.confirm = function()
	return 3
end
keys("<Space>q")
assert(vim.api.nvim_get_current_buf() == shared and vim.bo[shared].modified, "Cancel must keep unsaved file open")
vim.fn.confirm = function()
	return 2
end
keys("<Space>q")
assert(#vim.api.nvim_list_wins() == 1, "Last close must keep Neovim open")
assert(
	not vim.api.nvim_buf_is_valid(shared) or not vim.bo[shared].buflisted,
	"Discard must remove the buffer-name entry"
)
vim.fn.confirm = confirm
local file = vim.fn.tempname() .. ".txt"
vim.fn.writefile({ "original" }, file)
vim.cmd.edit(file)
local saved = vim.api.nvim_get_current_buf()
vim.api.nvim_buf_set_lines(saved, 0, -1, false, { "saved changes" })
vim.fn.confirm = function()
	return 1
end
keys("<Space>q")
vim.fn.confirm = confirm
assert(vim.fn.readfile(file)[1] == "saved changes", "Save must write changes before closing")
assert(
	not vim.api.nvim_buf_is_valid(saved) or not vim.bo[saved].buflisted,
	"Saved close must remove buffer from name bar"
)
vim.fn.delete(file)
local prefix = vim.fn.tempname()
local keep = prefix .. "-kept.txt"
local remove = prefix .. "-closed.txt"
vim.fn.writefile({ "keep" }, keep)
vim.fn.writefile({ "close" }, remove)
vim.cmd.edit(keep)
vim.cmd.edit(remove)
local function bar()
	return vim.api.nvim_eval_statusline(
		vim.wo.winbar,
		{ winid = vim.api.nvim_get_current_win(), use_winbar = true, maxwidth = 500 }
	).str
end
assert(bar():find("-closed.txt", 1, true), "Open file must be in bar")
keys("<Space>q")
assert(not bar():find("-closed.txt", 1, true), "Closed file must disappear from bar")
assert(bar():find("-kept.txt", 1, true), "Other file must stay in bar")
vim.cmd.vsplit()
keys("<Space>q")
assert(bar():find("-kept.txt", 1, true), "Shared file label must remain while another view is open")
vim.fn.delete(keep)
vim.fn.delete(remove)
print("PASS shared views survive; last-view close removes name; Save/Discard/Cancel protect changes")
vim.cmd("qa!")
