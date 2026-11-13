local dap = require("dap")
local root = vim.g.dotfiles_root
local work = root .. "/.state/test-workspace"
vim.fn.mkdir(work, "p")
vim.fn.writefile({ "x = 40", "x += 2", "print(x)" }, work .. "/debug_sample.py")
vim.fn.writefile({ "let x = 40;", "x += 2;", "console.log(x);" }, work .. "/debug_sample.cjs")
local results = {}
for _, spec in ipairs({ { "python", "debug_sample.py" }, { "pwa-node", "debug_sample.cjs" } }) do
	vim.cmd.edit(work .. "/" .. spec[2])
	vim.api.nvim_win_set_cursor(0, { 2, 0 })
	dap.set_breakpoint()
	local stopped, done = false, false
	dap.listeners.after.event_stopped["smoke"] = function(session, body)
		stopped = true
		vim.defer_fn(function()
			session:request("continue", { threadId = body.threadId }, function() end)
		end, 250)
	end
	dap.listeners.after.event_terminated["smoke"] = function()
		done = true
	end
	dap.run({
		type = spec[1],
		request = "launch",
		name = "Smoke",
		program = work .. "/" .. spec[2],
		cwd = work,
		console = "internalConsole",
		pythonPath = root .. "/.tools/python/bin/python",
	})
	local ok = vim.wait(30000, function()
		return stopped and done
	end, 50)
	print((ok and "PASS " or "FAIL ") .. spec[1] .. " Neovim debugging: breakpoint and continuation")
	table.insert(results, { language = spec[1], passed = ok, stopped = stopped, terminated = done })
	vim.wait(250, function()
		return false
	end, 25)
	dap.close()
	dap.clear_breakpoints()
end
vim.fn.writefile({ vim.json.encode(results) }, root .. "/.state/dap-results.json")
for _, r in ipairs(results) do
	if not r.passed then
		vim.cmd("cquit 1")
	end
end
vim.cmd("qa!")
