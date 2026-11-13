local dir = vim.fn.tempname()
vim.fn.mkdir(dir, "p")
dir = vim.uv.fs_realpath(dir)
vim.fn.writefile({ "base" }, dir .. "/base.txt")
vim.fn.writefile({ "first", "match here", "last" }, dir .. "/hit.txt")
vim.cmd.edit(dir .. "/base.txt")
local base = vim.api.nvim_get_current_win()
local tab_count = #vim.api.nvim_list_tabpages()
local api = require("nvim-tree.api")
local grep_actions = require("fzf-lua.config").normalize_opts({}, "grep").actions
local function verify(direction, source)
	local opened = vim.api.nvim_get_current_win()
	assert(opened ~= base, "A new split should open")
	assert(vim.api.nvim_buf_get_name(0) == dir .. "/hit.txt", "Selected file should open")
	assert(#vim.api.nvim_list_tabpages() == tab_count, "Splits should not create tab pages")
	local p = vim.api.nvim_win_get_position(opened)
	local b = vim.api.nvim_win_get_position(base)
	local ok = direction == "h" and p[2] < b[2]
		or direction == "l" and p[2] > b[2]
		or direction == "j" and p[1] > b[1]
		or direction == "k" and p[1] < b[1]
	assert(ok, source .. " " .. direction .. " opened on wrong side")
	local size = (direction == "h" or direction == "l") and vim.api.nvim_win_get_width or vim.api.nvim_win_get_height
	assert(math.abs(size(opened) - size(base)) <= 1, "New adjacent panes must be evenly sized")
	assert(
		not vim.wo[opened].winfixwidth and not vim.wo[opened].winfixheight,
		"Editor must not inherit fixed sidebar dimensions"
	)
	if source == "grep" then
		assert(vim.api.nvim_win_get_cursor(0)[1] == 2, "Grep must jump to the matched line")
	end
	assert(not api.tree.is_visible(), "Explorer should close on file open")
	vim.cmd.close()
	vim.api.nvim_set_current_win(base)
	print("PASS " .. source .. " " .. direction .. ": correct split, focused file, same tab")
end
for _, direction in ipairs({ "h", "j", "k", "l" }) do
	local action = grep_actions["ctrl-" .. direction]
	if type(action) == "table" then
		action = action.fn
	end
	assert(type(action) == "function", "Grep directional binding missing")
	action({ dir .. "/hit.txt:2:2:match here" }, {})
	verify(direction, "grep")
end
for _, direction in ipairs({ "h", "j", "k", "l" }) do
	api.tree.open({ path = dir })
	for row, text in ipairs(vim.api.nvim_buf_get_lines(0, 0, -1, false)) do
		if text:match("hit%.txt$") then
			vim.api.nvim_win_set_cursor(0, { row, 0 })
			break
		end
	end
	local mapping = vim.fn.maparg("<C-" .. direction .. ">", "n", false, true)
	assert(type(mapping.callback) == "function")
	mapping.callback()
	verify(direction, "tree")
end
-- Reproduce opening a picker from a later split rather than the first window.
vim.fn.writefile({ "second editor" }, dir .. "/second.txt")
for _, source in ipairs({ "grep", "tree" }) do
	for _, direction in ipairs({ "h", "j", "k", "l" }) do
		vim.api.nvim_set_current_win(base)
		vim.cmd.only()
		vim.cmd("rightbelow vsplit " .. vim.fn.fnameescape(dir .. "/second.txt"))
		local origin = vim.api.nvim_get_current_win()
		if source == "grep" then
			-- Even if picker teardown focuses an unrelated editor, its saved context wins.
			vim.api.nvim_set_current_win(base)
			local action = grep_actions["ctrl-" .. direction]
			if type(action) == "table" then
				action = action.fn
			end
			action({ dir .. "/hit.txt:2:2:match here" }, { __CTX = { winid = origin } })
		else
			api.tree.open({ path = dir })
			for row, text in ipairs(vim.api.nvim_buf_get_lines(0, 0, -1, false)) do
				if text:match("hit%.txt$") then
					vim.api.nvim_win_set_cursor(0, { row, 0 })
					break
				end
			end
			vim.fn.maparg("<C-" .. direction .. ">", "n", false, true).callback()
		end
		local opened = vim.api.nvim_get_current_win()
		local first_pos = vim.api.nvim_win_get_position(base)
		local origin_pos = vim.api.nvim_win_get_position(origin)
		local opened_pos = vim.api.nvim_win_get_position(opened)
		assert(vim.api.nvim_buf_get_name(0) == dir .. "/hit.txt", "Must focus the opened file")
		assert(not api.tree.is_visible(), "Tree must close")
		if direction == "h" then
			assert(
				first_pos[2] < opened_pos[2] and opened_pos[2] < origin_pos[2],
				"Must split left of originating editor, not first editor"
			)
		elseif direction == "l" then
			assert(
				first_pos[2] < origin_pos[2] and origin_pos[2] < opened_pos[2],
				"Must split right of originating editor"
			)
		else
			assert(
				opened_pos[2] == origin_pos[2] and origin_pos[2] > first_pos[2],
				"Horizontal split must belong to originating editor column"
			)
			assert(
				direction == "j" and opened_pos[1] > origin_pos[1] or direction == "k" and opened_pos[1] < origin_pos[1],
				"Wrong vertical direction"
			)
		end
		local size = (direction == "h" or direction == "l") and vim.api.nvim_win_get_width
			or vim.api.nvim_win_get_height
		assert(math.abs(size(opened) - size(origin)) <= 1, "Origin and new pane must be evenly sized")
		if direction == "h" or direction == "l" then
			assert(math.abs(size(base) - size(origin)) <= 1, "All adjacent columns must be evenly sized")
		end
		print("PASS " .. source .. " " .. direction .. ": split is relative to second editor, not first")
	end
end
vim.api.nvim_set_current_win(base)
vim.cmd.only()
api.tree.open({ path = dir })
local sidebar = vim.api.nvim_get_current_win()
local width = vim.api.nvim_win_get_width(sidebar)
require("user.windows").equalize()
assert(vim.api.nvim_win_get_width(sidebar) == width, "Balancing must preserve sidebar width")
print("PASS balanced pane dimensions and fixed explorer sidebar width")
vim.cmd("qa!")
