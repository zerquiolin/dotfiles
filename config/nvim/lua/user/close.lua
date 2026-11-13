local M = {}
function M.view()
	local closing = vim.api.nvim_get_current_buf()
	local shared = #vim.fn.win_findbuf(closing) > 1
	if not shared and vim.bo[closing].modified then
		local name = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(closing), ":t")
		if name == "" then
			name = "[Untitled]"
		end
		local choice = vim.fn.confirm("Save changes to " .. name .. "?", "&Save\n&Discard\n&Cancel", 3)
		if choice == 1 then
			local ok, err = pcall(vim.cmd.write)
			if not ok then
				vim.notify(tostring(err), vim.log.levels.ERROR)
				return
			end
			if vim.bo[closing].modified then
				return
			end
		elseif choice == 2 then
			vim.bo[closing].modified = false
		else
			return
		end
	end
	if #vim.api.nvim_tabpage_list_wins(0) > 1 then
		vim.cmd("confirm close")
	elseif #vim.api.nvim_list_tabpages() > 1 then
		vim.cmd("confirm tabclose")
	else
		-- Keep Neovim open without deleting a buffer that another tab may share.
		local current = vim.api.nvim_get_current_buf()
		local alternate = vim.fn.bufnr("#")
		if
			alternate ~= current
			and alternate > 0
			and vim.api.nvim_buf_is_valid(alternate)
			and vim.bo[alternate].buflisted
		then
			vim.api.nvim_win_set_buf(0, alternate)
		else
			vim.cmd.enew()
		end
	end
	-- Only remove the buffer-name entry after its last view has closed.
	if vim.api.nvim_buf_is_valid(closing) and #vim.fn.win_findbuf(closing) == 0 and not vim.bo[closing].modified then
		vim.api.nvim_buf_delete(closing, { force = false })
	end
end
return M
