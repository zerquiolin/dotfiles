vim.api.nvim_create_user_command("Format", function()
	require("conform").format({ async = true })
end, {})
vim.api.nvim_create_user_command("FormatToggle", function()
	vim.b.disable_autoformat = not vim.b.disable_autoformat
	vim.notify("Autoformat " .. (vim.b.disable_autoformat and "off" or "on"))
end, {})
vim.api.nvim_create_user_command("Build", function()
	if vim.bo.filetype == "tex" then
		vim.cmd.VimtexCompile()
	else
		vim.notify("Use the project's build command in the terminal")
	end
end, {})
vim.api.nvim_create_user_command("OpenPDF", function()
	vim.cmd.VimtexView()
end, {})

local function open_command(argv, label)
	vim.cmd("botright 12new")
	vim.fn.termopen(argv)
	vim.cmd.startinsert()
	vim.notify(label, vim.log.levels.INFO, { title = "Run" })
end

vim.api.nvim_create_user_command("Project", function()
	require("user.sessions").select()
end, { desc = "Choose and restore a project session" })

vim.api.nvim_create_user_command("Pdf", function()
	vim.cmd.OpenPDF()
end, { desc = "Open the LaTeX PDF" })

vim.api.nvim_create_user_command("Run", function(opts)
	local file = vim.api.nvim_buf_get_name(0)
	if file == "" then
		vim.notify("Save the current file before running it.", vim.log.levels.WARN)
		return
	end
	local argv
	if opts.args ~= "" then
		argv = vim.fn.split(opts.args)
	elseif vim.bo.filetype == "python" then
		local venv = vim.env.VIRTUAL_ENV
		local project_venv = vim.fn.finddir(".venv", ".;")
		local python = venv and (venv .. "/bin/python")
			or (project_venv ~= "" and (project_venv .. "/bin/python"))
			or "python3"
		argv = { python, file }
	elseif vim.bo.filetype == "javascript" then
		argv = { "node", file }
	elseif vim.bo.filetype == "typescript" or vim.bo.filetype == "typescriptreact" then
		local tsx = vim.fn.getcwd() .. "/node_modules/.bin/tsx"
		if vim.fn.executable(tsx) ~= 1 then
			vim.notify(
				"TypeScript runner not found. Install tsx in this project or use :Run <command>.",
				vim.log.levels.WARN
			)
			return
		end
		argv = { tsx, file }
	elseif vim.bo.filetype == "tex" then
		vim.cmd.Build()
		return
	else
		vim.notify("No default runner for " .. vim.bo.filetype .. ". Use :Run <command>.", vim.log.levels.WARN)
		return
	end
	open_command(argv, "Running " .. vim.fn.fnamemodify(file, ":t"))
end, { nargs = "*", desc = "Run current file or a supplied command" })

vim.api.nvim_create_user_command("MD", function()
	require("user.markdown").open()
end, { desc = "Preview saved Markdown in a scrollable floating window" })

vim.keymap.set("n", "<leader>cf", "<Cmd>Format<CR>", { desc = "Format" })
