local shortcut
local function keys(s)
	s = s:gsub("<F16>", shortcut or "<F16>")
	vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(s, true, false, true), "xt", false)
end
for _, binding in ipairs({ "<F16>", "<D-/>" }) do
	shortcut = binding
	for _, spec in ipairs({ { "python", "# " }, { "javascript", "// " }, { "typescript", "// " }, { "tex", "% " } }) do
		vim.cmd.enew({ bang = true })
		vim.bo.filetype = spec[1]
		vim.api.nvim_buf_set_lines(0, 0, -1, false, { "first", "second", "third" })
		vim.api.nvim_win_set_cursor(0, { 1, 0 })
		keys("<F16>")
		assert(vim.api.nvim_get_current_line() == spec[2] .. "first", spec[1] .. " line commenting failed")
		keys("<F16>")
		assert(vim.api.nvim_get_current_line() == "first", spec[1] .. " uncomment failed")
		keys("Vj<F16>")
		local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
		assert(
			lines[1] == spec[2] .. "first" and lines[2] == spec[2] .. "second" and lines[3] == "third",
			spec[1] .. " selected comments failed"
		)
		keys("ggVj<F16>")
		lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
		assert(lines[1] == "first" and lines[2] == "second", spec[1] .. " selection uncomment failed")
		keys("ggi<F16><Esc>")
		assert(
			vim.api.nvim_buf_get_lines(0, 0, 1, false)[1] == spec[2] .. "first",
			spec[1] .. " insert mode comments failed"
		)
		print("PASS " .. spec[1] .. ": line, selection, uncomment and insert-mode comment shortcut")
	end
end
vim.cmd("qa!")
