local M = {}
local preview_win, preview_buf, source_buf
function M.open()
	local current = vim.api.nvim_get_current_buf()
	if current ~= preview_buf then
		source_buf = current
	end
	if not source_buf or not vim.api.nvim_buf_is_valid(source_buf) then
		return
	end
	local file = vim.api.nvim_buf_get_name(source_buf)
	if vim.bo[source_buf].filetype ~= "markdown" or file == "" or vim.fn.filereadable(file) ~= 1 then
		vim.notify(":MD needs a saved Markdown file.", vim.log.levels.WARN)
		return
	end
	if vim.fn.executable("glow") ~= 1 then
		vim.notify("Glow is missing. Run brew install glow.", vim.log.levels.WARN)
		return
	end
	if preview_win and vim.api.nvim_win_is_valid(preview_win) then
		vim.api.nvim_set_current_win(preview_win)
		vim.cmd.startinsert()
		return
	end
	local origin = vim.api.nvim_get_current_win()
	local buf = vim.api.nvim_create_buf(false, true)
	local width = math.max(1, math.floor(vim.o.columns * 0.88))
	local height = math.max(1, math.floor(vim.o.lines * 0.82))
	local win = vim.api.nvim_open_win(buf, true, {
		relative = "editor",
		width = width,
		height = height,
		row = math.max(0, math.floor((vim.o.lines - height) / 2) - 1),
		col = math.floor((vim.o.columns - width) / 2),
		style = "minimal",
		border = "rounded",
		title = " " .. vim.fn.fnamemodify(file, ":t") .. " · Preview ",
		footer = " j/k scroll · q / Esc close ",
		footer_pos = "right",
	})
	preview_win, preview_buf = win, buf
	vim.bo[buf].bufhidden = "wipe"
	vim.wo[win].number = false
	vim.wo[win].relativenumber = false
	local function close()
		if vim.api.nvim_win_is_valid(win) then
			vim.api.nvim_win_close(win, true)
		end
		if vim.api.nvim_win_is_valid(origin) then
			vim.api.nvim_set_current_win(origin)
		end
	end
	local job = vim.fn.termopen(
		{ "glow", "--style", "dark", "--width", tostring(math.min(width - 4, 100)), "--pager", file },
		{
			env = { PAGER = "less -R", LESS = "-R", TERM = "xterm-256color" },
			on_exit = function(_, code)
				vim.schedule(function()
					close()
					if code ~= 0 and code ~= 129 and code ~= 143 then
						vim.notify("Markdown preview exited (" .. code .. ")", vim.log.levels.WARN)
					end
				end)
			end,
		}
	)
	vim.api.nvim_create_autocmd("WinClosed", {
		pattern = tostring(win),
		once = true,
		callback = function()
			if vim.fn.jobwait({ job }, 0)[1] == -1 then
				vim.fn.jobstop(job)
			end
		end,
	})
	for _, key in ipairs({ "q", "<Esc>" }) do
		vim.keymap.set({ "n", "t" }, key, close, { buffer = buf, silent = true, nowait = true })
	end
	vim.cmd.startinsert()
end
return M
