local M = {}
function M.setup()
	vim.o.winborder = "rounded"
	vim.ui.select = function(items, opts, callback)
		require("fzf-lua").register_ui_select({ winopts = { border = "rounded", width = 0.7, height = 0.5 } })
		vim.ui.select(items, opts, callback)
	end
	vim.ui.input = function(opts, callback)
		local origin = vim.api.nvim_get_current_win()
		local buf = vim.api.nvim_create_buf(false, true)
		local width = math.max(1, math.min(68, vim.o.columns - 4))
		local win = vim.api.nvim_open_win(buf, true, {
			relative = "editor",
			row = math.max(0, math.floor(vim.o.lines * 0.35)),
			col = math.max(0, math.floor((vim.o.columns - width) / 2)),
			width = width,
			height = 1,
			style = "minimal",
			border = "rounded",
			title = " " .. (opts.prompt or "Input") .. " ",
			title_pos = "left",
		})
		vim.api.nvim_buf_set_lines(buf, 0, -1, false, { opts.default or "" })
		local done = false
		local function finish(value)
			if done then
				return
			end
			done = true
			vim.cmd.stopinsert()
			if vim.api.nvim_win_is_valid(win) then
				vim.api.nvim_win_close(win, true)
			end
			if vim.api.nvim_win_is_valid(origin) then
				vim.api.nvim_set_current_win(origin)
			end
			vim.schedule(function()
				callback(value)
			end)
		end
		vim.keymap.set({ "i", "n" }, "<CR>", function()
			finish(vim.api.nvim_buf_get_lines(buf, 0, 1, false)[1])
		end, { buffer = buf })
		vim.keymap.set({ "i", "n" }, "<Esc>", function()
			finish(nil)
		end, { buffer = buf })
		vim.api.nvim_create_autocmd("WinClosed", {
			pattern = tostring(win),
			once = true,
			callback = function()
				finish(nil)
			end,
		})
		vim.cmd.startinsert()
	end

	local function palette()
		local actions = {
			{
				"Leave project · keep running",
				function()
					vim.cmd.ProjectLeave()
				end,
			},
			{
				"Projects · restore editor session",
				function()
					vim.cmd.Project()
				end,
			},
			{
				"Workspaces · terminal sidebar",
				function()
					vim.cmd("botright 16split")
					vim.fn.termopen({ "work", "open", "--layout", "shell" })
					vim.cmd.startinsert()
				end,
			},
			{
				"Find files",
				function()
					require("fzf-lua").files()
				end,
			},
			{
				"Search text",
				function()
					require("fzf-lua").live_grep()
				end,
			},
			{
				"Diagnostics",
				function()
					require("fzf-lua").diagnostics_workspace()
				end,
			},
			{
				"References",
				function()
					require("fzf-lua").lsp_references()
				end,
			},
			{
				"Format file",
				function()
					vim.cmd.Format()
				end,
			},
			{
				"Tasks · run",
				function()
					vim.cmd.Run()
				end,
			},
			{
				"Task output · quickfix",
				function()
					vim.cmd.copen()
				end,
			},
			{
				"Git",
				function()
					vim.cmd.LazyGit()
				end,
			},
			{
				"All editor commands",
				function()
					require("fzf-lua").commands()
				end,
			},
		}
		vim.ui.select(actions, {
			prompt = "Commands",
			format_item = function(x)
				return x[1]
			end,
		}, function(x)
			if x then
				x[2]()
			end
		end)
	end
	vim.api.nvim_create_user_command("Commands", palette, {})
	vim.keymap.set("n", "<leader><leader>", palette, { desc = "Command palette" })
end
return M
