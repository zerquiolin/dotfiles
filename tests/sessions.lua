local dir = vim.fn.tempname()
vim.fn.mkdir(dir, "p")
local project_dir = vim.uv.fs_realpath(dir)
vim.fn.writefile({ "one" }, dir .. "/one.py")
vim.fn.writefile({ "two" }, dir .. "/two.py")
vim.cmd.cd(dir)
vim.cmd.edit("one.py")
vim.cmd("vsplit two.py")

local sessions = require("user.sessions")
assert(sessions.enabled, "Project session auto-save should be enabled")
assert(not vim.o.sessionoptions:match("terminal"), "Terminal processes should not be captured in sessions")
assert(
	#vim.api.nvim_get_autocmds({ group = "ProjectSessions", event = "VimLeavePre" }) > 0,
	"Sessions should auto-save on exit"
)
assert(
	vim.fn.maparg("<leader>ws", "n", false, true).desc == "Save project session",
	"Session save shortcut should be registered"
)

assert(sessions.save({ quiet = true }), "Saving should succeed")
local saved
for _, candidate in ipairs(sessions.list()) do
	if candidate.root == project_dir then
		saved = candidate
		break
	end
end
assert(saved and saved.root == project_dir, "Saving should create a session for the current project")
local session_file = saved.path
local session_text = table.concat(vim.fn.readfile(session_file), "\n")
assert(session_text:find("one.py", 1, true), "Session should retain the first file")
assert(session_text:find("two.py", 1, true), "Session should retain the second file")

vim.fn.writefile({ "three" }, dir .. "/three.py")
vim.cmd.edit("three.py")
vim.api.nvim_exec_autocmds("VimLeavePre", { modeline = false })
session_text = table.concat(vim.fn.readfile(session_file), "\n")
assert(session_text:find("three.py", 1, true), "Exit should automatically update the project session")

vim.cmd.only()
vim.cmd.enew()
assert(sessions.restore(), "Restoring the current project session should succeed")
assert(vim.fn.getcwd() == project_dir, "Restoring should return to the project directory")
assert(#vim.api.nvim_list_wins() == 2, "Restoring should recreate the split layout")
local restored = {}
for _, buf in ipairs(vim.api.nvim_list_bufs()) do
	local name = vim.api.nvim_buf_get_name(buf)
	if name ~= "" then
		restored[vim.fn.fnamemodify(name, ":t")] = true
	end
end
assert(restored["one.py"] and restored["two.py"], "Restoring should reopen both project files")

sessions.disable()
vim.fn.delete(session_file)
local metadata_file = session_file:gsub("%.vim$", ".json")
vim.fn.delete(metadata_file)
vim.fn.delete(dir, "rf")
print("PASS project sessions save and restore files, split layout, and working directory")
vim.cmd("qa!")
