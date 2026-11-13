local M = { last_editor = {} }
function M.is_editor(win)
	if not win or not vim.api.nvim_win_is_valid(win) then
		return false
	end
	if vim.api.nvim_win_get_tabpage(win) ~= vim.api.nvim_get_current_tabpage() then
		return false
	end
	local buf = vim.api.nvim_win_get_buf(win)
	return vim.api.nvim_win_get_config(win).relative == ""
		and vim.bo[buf].buftype == ""
		and vim.bo[buf].filetype ~= "NvimTree"
end
function M.capture()
	local win = vim.api.nvim_get_current_win()
	if M.is_editor(win) then
		M.last_editor[vim.api.nvim_get_current_tabpage()] = win
	end
end
function M.origin(preferred)
	if M.is_editor(preferred) then
		return preferred
	end
	local current = vim.api.nvim_get_current_win()
	if M.is_editor(current) then
		return current
	end
	local previous = M.last_editor[vim.api.nvim_get_current_tabpage()]
	if M.is_editor(previous) then
		return previous
	end
end
function M.equalize()
	for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
		if M.is_editor(win) then
			-- A split created from the sidebar may inherit its fixed dimensions.
			vim.wo[win].winfixwidth = false
			vim.wo[win].winfixheight = false
		end
	end
	vim.cmd("wincmd =")
end
function M.setup()
	local group = vim.api.nvim_create_augroup("EditorOrigin", { clear = true })
	vim.api.nvim_create_autocmd("WinLeave", { group = group, callback = M.capture })
	M.capture()
end
return M
