local M = {}
function M.highlights()
	for _, name in ipairs({ "NvimTreeFolderName", "NvimTreeOpenedFolderName", "NvimTreeEmptyFolderName" }) do
		vim.api.nvim_set_hl(0, name, { fg = "#b5bfcc", bold = false })
	end
	vim.api.nvim_set_hl(0, "NvimTreeFolderIcon", { fg = "#89ddff" })
	vim.api.nvim_set_hl(0, "NvimTreeIndentMarker", { fg = "#343d48" })
	vim.api.nvim_set_hl(0, "NvimTreeRootFolder", { fg = "#a6accd", bold = false })
	vim.api.nvim_set_hl(0, "NvimTreeFolderArrowClosed", { fg = "#7e8c9e" })
	vim.api.nvim_set_hl(0, "NvimTreeFolderArrowOpen", { fg = "#7e8c9e" })
	vim.api.nvim_set_hl(0, "NvimTreeNormal", { fg = "#b5bfcc", bg = "NONE" })
	vim.api.nvim_set_hl(0, "NvimTreeNormalNC", { fg = "#b5bfcc", bg = "NONE" })
	vim.api.nvim_set_hl(0, "NvimTreeCursorLine", { bg = "#252b34" })
end
function M.expand()
	local api = require("nvim-tree.api")
	local node = api.tree.get_node_under_cursor()
	if not node or not node.parent then
		return
	end
	if node.type == "directory" then
		if not node.open then
			api.node.open.edit(node)
		end
	else
		api.node.open.no_window_picker(node)
	end
end
function M.collapse()
	local api = require("nvim-tree.api")
	local node = api.tree.get_node_under_cursor()
	if not node or not node.parent then
		return
	end
	if node.type == "directory" and node.open then
		api.node.open.edit(node)
	else
		api.node.navigate.parent(node)
	end
end
function M.create(directory)
	local api = require("nvim-tree.api")
	local node = api.tree.get_node_under_cursor()
	if not node then
		return
	end
	local dir = node.type == "directory" and node.absolute_path or vim.fs.dirname(node.absolute_path)
	vim.ui.input({ prompt = directory and "Directory name: " or "File name: " }, function(name)
		if not name or name == "" then
			return
		end
		if name:match("^/") or name:match("^~") then
			vim.notify("Use a relative name", vim.log.levels.ERROR)
			return
		end
		for part in name:gmatch("[^/]+") do
			if part == ".." then
				vim.notify("Use a name inside the selected directory", vim.log.levels.ERROR)
				return
			end
		end
		local path = dir .. "/" .. name
		if vim.uv.fs_lstat(path) then
			vim.notify("Already exists", vim.log.levels.WARN)
			return
		end
		local ok, err = pcall(function()
			if directory then
				assert(vim.fn.mkdir(path, "p") == 1, "Could not create directory")
			else
				vim.fn.mkdir(vim.fs.dirname(path), "p")
				local fd, why = vim.uv.fs_open(path, "wx", 420)
				assert(fd, why)
				vim.uv.fs_close(fd)
			end
		end)
		if not ok then
			vim.notify(tostring(err), vim.log.levels.ERROR)
			return
		end
		if node.type == "directory" and not node.open then
			api.node.open.edit(node)
		end
		api.tree.reload()
	end)
end
function M.split(command)
	local api = require("nvim-tree.api")
	local node = api.tree.get_node_under_cursor()
	if not node or node.type == "directory" then
		return
	end
	local origin = require("user.windows").origin()
	if origin then
		vim.api.nvim_set_current_win(origin)
	end
	vim.cmd(command .. " " .. vim.fn.fnameescape(node.absolute_path))
	local opened_win = vim.api.nvim_get_current_win()
	api.tree.close()
	if vim.api.nvim_win_is_valid(opened_win) then
		vim.api.nvim_set_current_win(opened_win)
	end
	require("user.windows").equalize()
end
function M.attach(buf)
	local api = require("nvim-tree.api")
	api.map.on_attach.default(buf)
	for _, key in ipairs({ "s", "<C-j>", "<C-k>" }) do
		pcall(vim.keymap.del, "n", key, { buffer = buf })
	end
	local function map(key, fn, desc)
		vim.keymap.set("n", key, fn, { buffer = buf, noremap = true, silent = true, desc = desc })
	end
	map("l", M.expand, "Expand folder / open file")
	map("h", M.collapse, "Collapse folder / focus parent")
	for direction, command in pairs(require("user.search").directions) do
		map("<C-" .. direction .. ">", function()
			M.split(command)
		end, "Open file " .. direction)
	end
	map("nf", function()
		M.create(false)
	end, "Create file")
	map("nd", function()
		M.create(true)
	end, "Create directory")
	map("<leader>ee", api.tree.toggle, "Toggle explorer")
	map("<leader>pv", function()
		api.node.open.preview(nil, { focus = true })
	end, "Preview file")
	for key, command in pairs({
		osl = "rightbelow vsplit",
		osh = "leftabove vsplit",
		ovj = "rightbelow split",
		ovk = "leftabove split",
	}) do
		map("<leader>" .. key, function()
			M.split(command)
		end, "Open file in split")
	end
	-- Keep the user's window-navigation family even over the tree's default mappings.
	for _, key in ipairs({ "h", "j", "k", "l" }) do
		map("s" .. key, "<C-w>" .. key, "Focus window")
	end
end
return M
