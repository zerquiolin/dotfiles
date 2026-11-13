local M = {}
local buf
function M.toggle()
	if buf and vim.api.nvim_buf_is_valid(buf) then
		for _, win in ipairs(vim.fn.win_findbuf(buf)) do
			if vim.api.nvim_win_is_valid(win) then
				vim.api.nvim_win_close(win, false)
				return
			end
		end
	end
	vim.cmd("botright 12split")
	if buf and vim.api.nvim_buf_is_valid(buf) then
		vim.api.nvim_win_set_buf(0, buf)
	else
		vim.cmd.terminal()
		buf = vim.api.nvim_get_current_buf()
	end
	vim.cmd.startinsert()
end
return M
