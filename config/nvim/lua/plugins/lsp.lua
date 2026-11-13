return {
	{
		"neovim/nvim-lspconfig",
		event = { "BufReadPre", "BufNewFile" },
		dependencies = { "saghen/blink.cmp" },
		config = function()
			vim.lsp.config("*", { capabilities = require("blink.cmp").get_lsp_capabilities() })
			vim.lsp.config("basedpyright", {
				settings = {
					basedpyright = {
						analysis = { diagnosticMode = "openFilesOnly", typeCheckingMode = "standard" },
					},
				},
			})
			vim.lsp.config("ruff", {
				on_attach = function(client)
					client.server_capabilities.hoverProvider = false
				end,
			})
			vim.lsp.config("texlab", {
				settings = {
					texlab = { build = { onSave = false }, chktex = { onEdit = false, onOpenAndSave = false } },
				},
			})
			vim.lsp.config("lua_ls", {
				settings = {
					Lua = { diagnostics = { globals = { "vim" } }, workspace = { checkThirdParty = false } },
				},
			})
			vim.lsp.enable({ "basedpyright", "ruff", "vtsls", "eslint", "texlab" })
			-- lua_ls is optional; enable when installed instead of starting a missing binary.
			if vim.fn.executable("lua-language-server") == 1 then
				vim.lsp.enable("lua_ls")
			end
			vim.api.nvim_create_autocmd("LspAttach", {
				callback = function(ev)
					if vim.b[ev.buf].large_file then
						vim.lsp.buf_detach_client(ev.buf, ev.data.client_id)
						return
					end
					local function map(key, action, desc)
						vim.keymap.set("n", key, action, { buffer = ev.buf, desc = desc })
					end
					map("gd", "<Cmd>FzfLua lsp_definitions<CR>", "Find definitions")
					map("<leader>ld", require("user.lsp").preview_info, "Preview definition")
					map("gr", "<Cmd>FzfLua lsp_references<CR>", "Find references")
					map("gi", "<Cmd>FzfLua lsp_implementations<CR>", "Find implementations")
					map("gy", "<Cmd>FzfLua lsp_typedefs<CR>", "Find type definitions")
					map("K", vim.lsp.buf.hover, "Documentation")
					map("<leader>rn", vim.lsp.buf.rename, "Rename")
					map("<leader>ca", vim.lsp.buf.code_action, "Code action")
					map("<leader>cd", vim.diagnostic.open_float, "Diagnostics")
				end,
			})
		end,
	},
}
