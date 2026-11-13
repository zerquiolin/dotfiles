local root = vim.g.dotfiles_root
local work = root .. "/.state/test-workspace"
vim.fn.mkdir(work, "p")
vim.fn.delete(work .. "/biome.json")
local function write(name, lines)
	vim.fn.writefile(lines, work .. "/" .. name)
end
write("pyproject.toml", { "[project]", 'name="smoke"', 'version="0.1.0"', 'requires-python=">=3.14"' })
write("tsconfig.json", { '{"compilerOptions":{"strict":true,"target":"ES2022"},"include":["*.ts"]}' })
write("package.json", { '{"private":true,"type":"module"}' })
write("eslint.config.mjs", { 'export default [{files:["**/*.js"],rules:{"no-unused-vars":"error"}}];' })
write("sample.py", { "def square(x: int) -> int:", "    return x*x", "", 'value: int = "bad"' })
write("sample.ts", { "const greeting:string=42;", "console.log(greeting)" })
write("sample.js", { "const unused=1;" })
write("main.tex", { "\\documentclass{article}", "\\begin{document}", "Hello, research.", "\\end{document}" })
vim.cmd.cd(work)
local results = {}
local function check(name, ok, detail)
	table.insert(results, { name = name, passed = not not ok, detail = detail })
	print((ok and "PASS " or "FAIL ") .. name .. (detail and ": " .. detail or ""))
end
local function names(buf)
	local n = {}
	for _, c in ipairs(vim.lsp.get_clients({ bufnr = buf })) do
		n[c.name] = c
	end
	return n
end
local specs = {
	{ "sample.py", { "basedpyright", "ruff" }, "ruff_format" },
	{ "sample.ts", { "vtsls" }, "prettier" },
	{ "sample.js", { "eslint" }, "prettier" },
	{ "main.tex", { "texlab" }, "company_latexindent" },
}
for _, spec in ipairs(specs) do
	vim.cmd.edit(work .. "/" .. spec[1])
	local buf = vim.api.nvim_get_current_buf()
	check(spec[1] .. " syntax parser", vim.treesitter.highlighter.active[buf] ~= nil)
	for _, server in ipairs(spec[2]) do
		local ok = vim.wait(20000, function()
			local c = names(buf)[server]
			return c and c.initialized
		end, 50)
		check(server .. " attached", ok)
	end
	if spec[1] == "sample.py" then
		check("Fuzzy LSP definitions", vim.fn.maparg("gd", "n", false, true).desc == "Find definitions")
		check("Fuzzy LSP references", vim.fn.maparg("gr", "n", false, true).desc == "Find references")
	end
	local err
	require("conform").format({ bufnr = buf, async = false, timeout_ms = 10000 }, function(e)
		err = e
	end)
	check(spec[1] .. " formatting", err == nil, err and tostring(err) or nil)
	if spec[1] == "sample.py" then
		check("Ruff changed code", vim.api.nvim_buf_get_lines(buf, 1, 2, false)[1] == "    return x * x")
		check(
			"Python diagnostics",
			vim.wait(15000, function()
				return #vim.diagnostic.get(buf) > 0
			end, 50)
		)
		vim.api.nvim_win_set_cursor(0, { 2, 11 })
		local client = names(buf).basedpyright
		local response = client
			and client:request_sync(
				"textDocument/hover",
				vim.lsp.util.make_position_params(0, client.offset_encoding),
				10000,
				buf
			)
		check("Python hover", response and response.result ~= nil)
	elseif spec[1] == "sample.ts" then
		check(
			"TS diagnostics",
			vim.wait(15000, function()
				return #vim.diagnostic.get(buf) > 0
			end, 50)
		)
		check(
			"Prettier changed code",
			vim.api.nvim_buf_get_lines(buf, 0, 1, false)[1] == "const greeting: string = 42;"
		)
	elseif spec[1] == "sample.js" then
		check(
			"ESLint diagnostics",
			vim.wait(15000, function()
				for _, d in ipairs(vim.diagnostic.get(buf)) do
					if d.source == "eslint" then
						return true
					end
				end
				return false
			end, 50)
		)
	elseif spec[1] == "main.tex" then
		check("VimTeX initialized", vim.b.vimtex ~= nil)
		check("VimTeX compile command", vim.fn.exists(":VimtexCompile") == 2)
		vim.cmd("write")
		local built = vim.system(
			{ "latexmk", "-pdf", "-interaction=nonstopmode", "-halt-on-error", "main.tex" },
			{ cwd = work, text = true }
		):wait(30000)
		check("LaTeX PDF build", built.code == 0 and vim.uv.fs_stat(work .. "/main.pdf") ~= nil)
	end
	vim.bo[buf].modified = false
end
write("biome.json", { '{"formatter":{"indentStyle":"space","indentWidth":4}}' })
vim.cmd.edit(work .. "/sample.ts")
local formatters = require("conform").list_formatters(0)
check("Project Biome selection", formatters[1] and formatters[1].name == "biome")
vim.bo.modified = false
require("lazy").load({ plugins = { "nvim-tree.lua", "fzf-lua", "nvim-dap", "multicursor.nvim", "copilot.lua" } })
check("File picker loaded", package.loaded["fzf-lua"] ~= nil)
check("Workspace symbol shortcut", vim.fn.maparg("<leader>fS", "n", false, true).desc == "Workspace symbols")
check("Multicursor loaded", package.loaded["multicursor-nvim"] ~= nil)
check("Python debugger configured", require("dap").adapters.python.command == root .. "/.tools/python/bin/python")
check("JS debugger configured", vim.uv.fs_stat(root .. "/.tools/debugger/js-debug/src/dapDebugServer.js") ~= nil)
check("Copilot configured", require("copilot.config").suggestion.keymap.accept == "<M-CR>")
for _, direction in ipairs({ "h", "j", "k", "l" }) do
	check(
		"Window shortcut s" .. direction,
		vim.fn.maparg("s" .. direction, "n") == "<C-W>" .. direction
			or vim.fn.maparg("s" .. direction, "n") == "<C-w>" .. direction
	)
end
local api = require("nvim-tree.api")
api.tree.open({ path = work })
check(
	"Explorer opens",
	vim.wait(5000, function()
		return vim.bo.filetype == "NvimTree"
			and table.concat(vim.api.nvim_buf_get_lines(0, 0, -1, false), "\n"):find("sample.py", 1, true) ~= nil
	end, 25)
)
for row, text in ipairs(vim.api.nvim_buf_get_lines(0, 0, -1, false)) do
	if text:match("%s+sample%.py$") then
		vim.api.nvim_win_set_cursor(0, { row, 0 })
		break
	end
end
require("user.explorer").split("rightbelow vsplit")
check(
	"Explorer closes after file opens",
	not api.tree.is_visible() and vim.api.nvim_buf_get_name(0) == work .. "/sample.py"
)
check(
	"Native completion matcher",
	vim.wait(30000, function()
		return require("blink.cmp.fuzzy").implementation_type == "rust"
	end, 50)
)
local failed = 0
for _, r in ipairs(results) do
	if not r.passed then
		failed = failed + 1
	end
end
vim.fn.writefile({ vim.json.encode(results) }, root .. "/.state/smoke-results.json")
vim.cmd(failed == 0 and "qa!" or "cquit 1")
