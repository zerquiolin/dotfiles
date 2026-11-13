local M = {}

local function preview_lines(location, documentation)
	local path = vim.uri_to_fname(location.targetUri or location.uri)
	local range = location.targetSelectionRange or location.range or location.targetRange
	local body = location.targetRange
	local source = vim.fn.readfile(path)
	local first = range.start.line + 1
	local last = math.min(#source, first + 13)
	if body and body["end"].line > range.start.line then
		last = math.min(last, body["end"].line + (body["end"].character > 0 and 1 or 0))
	end
	local ft = vim.filetype.match({ filename = path }) or "text"
	local indent = #(source[first]:match("^%s*") or "")
	local code, in_docstring, started = {}, false, false
	for index = first, last do
		local line = source[index]
		local text = vim.trim(line)
		if
			ft == "python"
			and index > first
			and text ~= ""
			and #(line:match("^%s*") or "") <= indent
			and (text:match("^def ") or text:match("^async def ") or text:match("^class ") or text:match("^@"))
		then
			break
		end
		-- The hover already supplies documentation; omit a leading Python docstring.
		if
			ft == "python"
			and index > first
			and not started
			and (text:sub(1, 3) == '"""' or text:sub(1, 3) == "'" .. "''")
		then
			local marker = text:sub(1, 3)
			if not text:sub(4):find(marker, 1, true) then
				in_docstring = marker
			end
			started = true
		elseif in_docstring then
			if text:find(in_docstring, 1, true) then
				in_docstring = false
			end
		else
			table.insert(code, line)
			if index > first and text ~= "" then
				started = true
			end
		end
	end
	while code[#code] == "" do
		table.remove(code)
	end
	local lines = {
		vim.fn.fnamemodify(path, ":h:t") .. "/" .. vim.fn.fnamemodify(path, ":t") .. ":" .. first,
		"",
		"Documentation",
		"",
	}
	vim.list_extend(
		lines,
		#documentation > 0 and documentation or { "No documentation supplied by the language server." }
	)
	vim.list_extend(lines, { "", "Implementation", "", "```" .. ft })
	vim.list_extend(lines, code)
	vim.list_extend(lines, { "```" })
	return lines
end

local function show_preview(location, documentation)
	local ok, lines = pcall(preview_lines, location, documentation)
	if not ok then
		vim.notify("Definition preview unavailable: " .. tostring(lines), vim.log.levels.WARN)
		return
	end
	local c = require("user.theme").palette()
	local normal = vim.api.nvim_get_hl(0, { name = "NormalFloat", link = false })
	local bg = normal.bg or c.surface
	vim.api.nvim_set_hl(0, "LspDefinitionFloat", { fg = c.text, bg = bg })
	vim.api.nvim_set_hl(0, "LspDefinitionBorder", { fg = c.muted, bg = bg })
	vim.api.nvim_set_hl(0, "LspDefinitionTitle", { fg = c.accent, bg = bg })
	vim.api.nvim_set_hl(0, "LspDefinitionMeta", { fg = c.muted, bg = bg, italic = false })
	vim.api.nvim_set_hl(0, "LspDefinitionSection", { fg = c.accent, bold = true })
	local buf, win = vim.lsp.util.open_floating_preview(lines, "markdown", {
		border = "rounded",
		focusable = true,
		focus_id = "function_insight",
		title = " ƒ Definition ",
		title_pos = "left",
		footer = " Space l d focus · q / Esc close ",
		footer_pos = "right",
		max_width = math.max(20, math.min(82, vim.o.columns - 8)),
		max_height = math.max(4, math.min(26, math.floor(vim.o.lines * 0.65))),
		wrap = true,
	})
	vim.wo[win].winhighlight =
		"NormalFloat:LspDefinitionFloat,FloatBorder:LspDefinitionBorder,FloatTitle:LspDefinitionTitle,FloatFooter:LspDefinitionMeta"
	vim.wo[win].number = false
	vim.wo[win].relativenumber = false
	vim.wo[win].signcolumn = "no"
	vim.wo[win].foldcolumn = "1"
	vim.wo[win].breakindent = true
	local actual = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
	for index, line in ipairs(actual) do
		local group = index == 1 and "LspDefinitionMeta"
			or ((line == "Documentation" or line == "Implementation") and "LspDefinitionSection" or nil)
		if group then
			vim.api.nvim_buf_add_highlight(buf, -1, group, index - 1, 0, -1)
		end
	end
	for _, key in ipairs({ "q", "<Esc>" }) do
		vim.keymap.set("n", key, "<Cmd>close<CR>", { buffer = buf, silent = true, nowait = true })
	end
end

function M.preview_info()
	local line = vim.api.nvim_win_get_cursor(0)[1] - 1
	if #vim.diagnostic.get(0, { lnum = line }) > 0 then
		local buf = vim.diagnostic.open_float(0, {
			scope = "line",
			border = "rounded",
			focusable = true,
			source = true,
			severity_sort = true,
			header = "Diagnostics",
			title = " Line diagnostics ",
			title_pos = "center",
			max_width = 90,
		})
		if buf then
			for _, key in ipairs({ "q", "<Esc>" }) do
				vim.keymap.set("n", key, "<Cmd>close<CR>", { buffer = buf, silent = true, nowait = true })
			end
		end
		return
	end
	M.preview_definition()
end

function M.preview_definition()
	local source_buf = vim.api.nvim_get_current_buf()
	vim.lsp.buf_request_all(source_buf, "textDocument/definition", function(client)
		return vim.lsp.util.make_position_params(0, client.offset_encoding)
	end, function(responses)
		if not vim.api.nvim_buf_is_valid(source_buf) then
			return
		end
		for client_id, response in pairs(responses) do
			local result = response.result
			if result then
				local location = vim.islist(result) and result[1] or result
				if location then
					local client = vim.lsp.get_client_by_id(client_id)
					local params = client and vim.lsp.util.make_position_params(0, client.offset_encoding)
					local function finish(hover)
						local docs = {}
						if hover and hover.contents then
							docs = vim.lsp.util.convert_input_to_markdown_lines(hover.contents)
						end
						show_preview(location, docs)
					end
					if client and params and client:supports_method("textDocument/hover", source_buf) then
						local accepted = client:request("textDocument/hover", params, function(err, hover)
							finish(not err and hover or nil)
						end, source_buf)
						if accepted then
							return
						end
					end
					finish(nil)
					return
				end
			end
		end
		vim.notify("No definition found for this symbol.", vim.log.levels.INFO)
	end)
end

return M
