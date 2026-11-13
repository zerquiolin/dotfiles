local path = vim.fn.tempname() .. ".txt"
vim.cmd.edit(path)
local function keys(s)
	vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(s, true, false, true), "xt", false)
end
for _, shortcut in ipairs({ "<F17>", "<D-s>" }) do
	for _, spec in ipairs({ { "normal", "<F17>" }, { "insert", "i<F17><Esc>" }, { "visual", "V<F17><Esc>" } }) do
		vim.api.nvim_buf_set_lines(0, 0, -1, false, { spec[1] .. " saved" })
		keys((spec[2]:gsub("<F17>", shortcut)))
		assert(vim.fn.readfile(path)[1] == spec[1] .. " saved", spec[1] .. " did not write to disk")
		assert(not vim.bo.modified, spec[1] .. " buffer still marked modified")
		print("PASS Cmd-S save from " .. spec[1] .. " mode")
	end
end
vim.fn.delete(path)
vim.cmd("qa!")
