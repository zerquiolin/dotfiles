local M = { enabled = true }

local session_dir = vim.fn.stdpath("state") .. "/sessions"
local project_markers = {
	".git",
	"package.json",
	"pyproject.toml",
	"requirements.txt",
	"Pipfile",
	"setup.py",
	"Cargo.toml",
	"go.mod",
	"Makefile",
	"main.tex",
}

local function project()
	local cwd = vim.uv.fs_realpath(vim.fn.getcwd()) or vim.fn.getcwd()
	local root = vim.fs.root(cwd, project_markers) or cwd
	root = vim.uv.fs_realpath(root) or root
	local result = vim.system({ "git", "-C", root, "branch", "--show-current" }, { text = true }):wait()
	local branch = result.code == 0 and vim.trim(result.stdout) or ""
	if branch == "main" or branch == "master" then
		branch = ""
	end
	return { root = root, cwd = cwd, branch = branch }
end

local function session_id(root, branch)
	return vim.fn.sha256(root .. "\0" .. (branch or ""))
end

local function paths(root, branch)
	local id = session_id(root, branch)
	return {
		id = id,
		path = session_dir .. "/" .. id .. ".vim",
		metadata_path = session_dir .. "/" .. id .. ".json",
	}
end

local function notify(message, level)
	vim.notify(message, level or vim.log.levels.INFO, { title = "Project sessions" })
end

local function file_buffers()
	local files = {}
	for _, buf in ipairs(vim.api.nvim_list_bufs()) do
		if vim.api.nvim_buf_is_loaded(buf) and vim.bo[buf].buftype == "" then
			local name = vim.api.nvim_buf_get_name(buf)
			if name ~= "" then
				table.insert(files, name)
			end
		end
	end
	return files
end

local function read_session(metadata_path)
	local ok, metadata = pcall(vim.json.decode, table.concat(vim.fn.readfile(metadata_path), "\n"))
	if not ok or type(metadata) ~= "table" or type(metadata.root) ~= "string" then
		return nil
	end
	local session_path = metadata_path:gsub("%.json$", ".vim")
	if vim.fn.filereadable(session_path) ~= 1 then
		return nil
	end
	metadata.path = session_path
	metadata.id = metadata_path:match("([^/]+)%.json$")
	return metadata
end

function M.current()
	return project()
end

function M.list()
	local sessions = {}
	for _, metadata_path in ipairs(vim.fn.glob(session_dir .. "/*.json", false, true)) do
		local session = read_session(metadata_path)
		if session then
			table.insert(sessions, session)
		end
	end
	table.sort(sessions, function(a, b)
		return (a.updated_at or 0) > (b.updated_at or 0)
	end)
	return sessions
end

local function restore_session(session)
	if not session or vim.fn.isdirectory(session.root) ~= 1 then
		notify("The project directory for that session no longer exists.", vim.log.levels.WARN)
		return false
	end
	local ok, err = pcall(function()
		vim.cmd("silent source " .. vim.fn.fnameescape(session.path))
	end)
	if not ok then
		notify("Could not restore session: " .. tostring(err), vim.log.levels.ERROR)
		return false
	end
	notify("Restored " .. vim.fn.fnamemodify(session.root, ":~"))
	return true
end

function M.save(opts)
	opts = type(opts) == "table" and opts or {}
	if not M.enabled then
		if not opts.quiet then
			notify("Session auto-save is disabled.", vim.log.levels.WARN)
		end
		return false
	end
	if #file_buffers() == 0 then
		if not opts.quiet then
			notify("Open a project file before saving a session.", vim.log.levels.WARN)
		end
		return false
	end

	local current = project()
	local destination = paths(current.root, current.branch)
	vim.fn.mkdir(session_dir, "p")
	local ok, err = pcall(function()
		vim.cmd("mksession! " .. vim.fn.fnameescape(destination.path))
	end)
	if not ok then
		if not opts.quiet then
			notify("Could not save session: " .. tostring(err), vim.log.levels.ERROR)
		end
		return false
	end
	local metadata = {
		root = current.root,
		cwd = current.cwd,
		branch = current.branch,
		updated_at = os.time(),
	}
	vim.fn.writefile({ vim.json.encode(metadata) }, destination.metadata_path)
	if not opts.quiet then
		notify("Saved " .. vim.fn.fnamemodify(current.root, ":~"))
	end
	return true
end

function M.restore()
	local current = project()
	local destination = paths(current.root, current.branch)
	local session = read_session(destination.metadata_path)
	if not session and current.branch ~= "" then
		destination = paths(current.root, "")
		session = read_session(destination.metadata_path)
	end
	if not session then
		notify("No saved session for " .. vim.fn.fnamemodify(current.root, ":~"), vim.log.levels.WARN)
		return false
	end
	return restore_session(session)
end

function M.restore_last()
	local sessions = M.list()
	if #sessions == 0 then
		notify("No saved project sessions yet.", vim.log.levels.WARN)
		return false
	end
	return restore_session(sessions[1])
end

function M.select()
	local sessions = M.list()
	if #sessions == 0 then
		notify("No saved project sessions yet.", vim.log.levels.WARN)
		return
	end
	vim.ui.select(sessions, {
		prompt = "Restore project session",
		format_item = function(session)
			local label = vim.fn.fnamemodify(session.root, ":~")
			return session.branch ~= "" and (label .. "  [" .. session.branch .. "]") or label
		end,
	}, restore_session)
end

function M.enable()
	M.enabled = true
	notify("Session auto-save is enabled.")
end

function M.disable()
	M.enabled = false
	notify("Session auto-save is disabled for this Neovim run.", vim.log.levels.WARN)
end

function M.setup()
	local group = vim.api.nvim_create_augroup("ProjectSessions", { clear = true })
	vim.api.nvim_create_autocmd("VimLeavePre", {
		group = group,
		callback = function()
			M.save({ quiet = true })
		end,
	})

	local map = vim.keymap.set
	map("n", "<leader>ws", M.save, { desc = "Save project session" })
	map("n", "<leader>wr", M.restore, { desc = "Restore project session" })
	map("n", "<leader>wS", M.select, { desc = "Choose project session" })
	map("n", "<leader>wl", M.restore_last, { desc = "Restore last session" })
	map("n", "<leader>wd", M.disable, { desc = "Disable session auto-save" })
	map("n", "<leader>we", M.enable, { desc = "Enable session auto-save" })

	vim.api.nvim_create_user_command("SessionSave", M.save, {})
	vim.api.nvim_create_user_command("SessionRestore", M.restore, {})
	vim.api.nvim_create_user_command("SessionSelect", M.select, {})
	vim.api.nvim_create_user_command("SessionRestoreLast", M.restore_last, {})
	vim.api.nvim_create_user_command("SessionStop", M.disable, {})
	vim.api.nvim_create_user_command("SessionStart", M.enable, {})
end

return M
