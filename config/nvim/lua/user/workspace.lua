local M = {}
local registration
local snapshot
function M.checkpoint()
	if not snapshot then
		return true
	end
	return pcall(function()
		vim.cmd("silent mksession! " .. vim.fn.fnameescape(snapshot))
	end)
end
function M.prepare_stop()
	for _, buf in ipairs(vim.api.nvim_list_bufs()) do
		if vim.bo[buf].modified then
			return false
		end
	end
	local files = false
	for _, buf in ipairs(vim.api.nvim_list_bufs()) do
		if vim.bo[buf].buftype == "" and vim.api.nvim_buf_get_name(buf) ~= "" then
			files = true
		end
	end
	if files and not require("user.sessions").save({ quiet = true }) then
		return false
	end
	return M.checkpoint()
end
function M.setup()
	local name = vim.env.WORK_SESSION
	if not name and vim.env.TMUX then
		local result = vim.system({ "tmux", "display-message", "-p", "#{session_name}" }, { text = true }):wait()
		if result.code == 0 then
			name = vim.trim(result.stdout)
		end
	end
	if not name or not name:match("^work%-%x+$") then
		return
	end
	local dir = vim.g.dotfiles_root .. "/.state/workspaces/" .. name
	vim.fn.mkdir(dir, "p")
	local socket = vim.v.servername
	if socket == "" then
		socket = vim.fn.serverstart()
	end
	registration = dir .. "/editor-" .. vim.fn.getpid() .. ".json"
	snapshot = vim.env.WORK_EDITOR_SNAPSHOT
		or (dir .. "/view-" .. (vim.env.TMUX_PANE or tostring(vim.fn.getpid())):gsub("[^%w]", "") .. ".vim")
	vim.fn.writefile(
		{ vim.json.encode({ socket = socket, pane = vim.env.TMUX_PANE, snapshot = snapshot }) },
		registration
	)
	vim.api.nvim_create_autocmd("VimLeavePre", {
		once = true,
		callback = function()
			M.checkpoint()
			vim.fn.delete(registration)
		end,
	})
	if vim.env.WORK_RESTORE == "1" then
		vim.api.nvim_create_autocmd("VimEnter", {
			once = true,
			nested = true,
			callback = function()
				if vim.fn.filereadable(snapshot) == 1 then
					local ok, err = pcall(vim.cmd, "silent source " .. vim.fn.fnameescape(snapshot))
					if not ok then
						vim.notify("Could not restore workspace: " .. tostring(err), vim.log.levels.ERROR)
					end
					return
				end
				local sessions = require("user.sessions")
				local current = sessions.current()
				for _, saved in ipairs(sessions.list()) do
					if saved.root == current.root and saved.branch == current.branch then
						sessions.restore()
						return
					end
				end
			end,
		})
	end
	local timer = vim.uv.new_timer()
	timer:start(
		30000,
		30000,
		vim.schedule_wrap(function()
			if vim.v.exiting ~= vim.NIL and vim.v.exiting ~= 0 then
				return
			end
			M.checkpoint()
			vim.system({ "work", "checkpoint", "--session", name }, {}, function() end)
		end)
	)
	vim.api.nvim_create_autocmd("VimLeavePre", {
		once = true,
		callback = function()
			timer:stop()
			timer:close()
		end,
	})
	vim.api.nvim_create_user_command("ProjectLeave", function()
		vim.system({ "work", "leave" }, {}, function(result)
			if result.code ~= 0 then
				vim.schedule(function()
					vim.notify(result.stderr, vim.log.levels.ERROR)
				end)
			end
		end)
	end, {})
end
return M
