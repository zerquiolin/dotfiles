local api = require("nvim-tree.api")
assert(
	vim.wait(3000, function()
		return vim.bo.filetype == "NvimTree" and api.tree.get_node_under_cursor() ~= nil
	end, 20),
	"Directory startup must open the tree"
)
local dir = api.tree.get_node_under_cursor().absolute_path
local function rows()
	return vim.api.nvim_buf_get_lines(0, 0, -1, false)
end
local function line(name)
	for i, text in ipairs(rows()) do
		if text:find(name, 1, true) then
			return i, text
		end
	end
end
local function select_node(name)
	assert(
		vim.wait(3000, function()
			return line(name) ~= nil
		end, 20),
		"Missing tree entry " .. name
	)
	vim.api.nvim_win_set_cursor(0, { line(name), 0 })
end
local function key(lhs)
	local mapping = vim.fn.maparg(lhs, "n", false, true)
	assert(type(mapping.callback) == "function", "Missing mapping " .. lhs)
	mapping.callback()
end
local input = vim.ui.input
for _, spec in ipairs({ { "nf", "created-file.txt", "file" }, { "nd", "created-folder", "directory" } }) do
	vim.api.nvim_win_set_cursor(0, { 1, 0 })
	vim.ui.input = function(_, callback)
		callback(spec[2])
	end
	key(spec[1])
	select_node(spec[2])
	assert(vim.uv.fs_stat(dir .. "/" .. spec[2]).type == spec[3])
	print("PASS tree " .. spec[1] .. ": creation and visible entry")
end
vim.ui.input = input
vim.fn.mkdir(dir .. "/src/nested", "p")
vim.fn.writefile({ 'print("nested")' }, dir .. "/src/nested/child.py")
vim.fn.writefile({ 'print("root")' }, dir .. "/root.py")
vim.fn.writefile({ "export default function App() {}" }, dir .. "/App.tsx")
api.tree.reload()
select_node("src")
assert(not line("nested"), "Folder should initially be collapsed")
key("l")
key("l")
select_node("nested")
local _, parent_text = line("nested")
key("l")
select_node("child.py")
local _, child_text = line("child.py")
assert(child_text:find("child.py", 1, true) > parent_text:find("nested", 1, true), "Child names must be indented")
assert(child_text:find("│", 1, true) or child_text:find("└", 1, true), "Children must show branch guides")
key("h")
assert(api.tree.get_node_under_cursor().name == "nested", "h on a file must focus its parent")
key("h")
assert(not line("child.py"), "h must collapse an open folder")
select_node("src")
key("<CR>")
assert(not line("nested"), "Enter on parent must hide descendants")
key("<C-l>")
assert(not line("nested"), "Directional opening must not toggle folders")
print("PASS l expands without toggling closed; h focuses parent/collapses; Enter toggles folders")
-- Creating inside a collapsed selected directory expands it and shows the result.
vim.ui.input = function(_, callback)
	callback("inside.txt")
end
key("nf")
vim.ui.input = input
select_node("inside.txt")
assert(vim.uv.fs_stat(dir .. "/src/inside.txt"), "nf should create inside selected folder")
key("<leader>osl")
assert(not api.tree.is_visible(), "Opening a file in a split must close the explorer")
assert(vim.api.nvim_buf_get_name(0) == dir .. "/src/inside.txt", "Split must focus the opened file")
print("PASS split opens file, closes tree and focuses editor")
api.tree.open({ path = dir })
assert(not vim.wo.number and not vim.wo.relativenumber, "Tree should hide line numbers")
local icon = require("nvim-web-devicons").get_icon("root.py", "py", { default = true })
assert(select(2, line("root.py")):find(icon, 1, true), "Python icon missing")
assert(line("src") < line("root.py"), "Folders must appear before files")
for _, direction in ipairs({ "h", "j", "k", "l" }) do
	assert(vim.fn.maparg("s" .. direction, "n") ~= "", "Window mapping missing")
end
for _, keyname in ipairs({ "j", "k" }) do
	assert(vim.fn.maparg(keyname, "n") == "", "Plain " .. keyname .. " must remain native navigation")
end
local folder_line = select(2, line("src"))
assert(folder_line:find("", 1, true) or folder_line:find("", 1, true), "Folder chevron missing")
assert(not folder_line:match("src/$"), "Folder labels should not have trailing slashes")
assert(not vim.api.nvim_get_hl(0, { name = "NvimTreeFolderName" }).bold, "Folder labels should use regular weight")
local react_icon = require("nvim-web-devicons").get_icon("App.tsx", "tsx", { default = true })
assert(select(2, line("App.tsx")):find(react_icon, 1, true), "React file icon missing")
print("PASS chevron folders, quiet labels, React/Python icons, native jk navigation, and window shortcuts")
select_node("root.py")
key("<C-l>")
assert(
	not api.tree.is_visible() and vim.api.nvim_buf_get_name(0) == dir .. "/root.py",
	"Ctrl-l on file must close tree and focus file"
)
api.tree.open({ path = dir })
select_node("root.py")
key("<CR>")
assert(
	not api.tree.is_visible() and vim.api.nvim_buf_get_name(0) == dir .. "/root.py",
	"Enter on file must close tree and focus file"
)
print("PASS directional and Enter opening close the explorer")
vim.cmd("qa!")
