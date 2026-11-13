local M = {}
function M.render()
	local win = tonumber(vim.g.statusline_winid) or vim.api.nvim_get_current_win()
	if not vim.api.nvim_win_is_valid(win) then
		return ""
	end
	local buf = vim.api.nvim_win_get_buf(win)
	if vim.bo[buf].buftype ~= "" or vim.bo[buf].filetype == "NvimTree" then
		return ""
	end
	local name = vim.api.nvim_buf_get_name(buf)
	local label = name ~= "" and vim.fn.fnamemodify(name, ":t") or "Untitled"
	if name ~= "" then
		label = vim.fn.fnamemodify(name, ":h:t") .. "/" .. label
	end
	return " %<"
		.. label:gsub("%%", "%%%%")
		.. (vim.bo[buf].modified and " ●" or "")
		.. (vim.bo[buf].readonly and " [RO]" or "")
		.. " "
end
function M.setup()
	vim.o.winbar = "%{%v:lua.require'user.windowbar'.render()%}"
	local function colors()
		local c = require("user.theme").palette()
		vim.api.nvim_set_hl(0, "WinBar", { fg = c.text, bg = c.surface, bold = true })
		vim.api.nvim_set_hl(0, "WinBarNC", { fg = c.muted, bg = "NONE" })
	end
	colors()
	local group = vim.api.nvim_create_augroup("WindowHeaders", { clear = true })
	vim.api.nvim_create_autocmd("ColorScheme", { group = group, callback = colors })
	vim.api.nvim_create_autocmd("WinLeave", {
		group = group,
		callback = function()
			vim.wo.cursorline = false
		end,
	})
	vim.api.nvim_create_autocmd("WinEnter", {
		group = group,
		callback = function()
			vim.wo.cursorline = vim.bo.buftype == "" and vim.bo.filetype ~= "NvimTree"
		end,
	})
end
return M
