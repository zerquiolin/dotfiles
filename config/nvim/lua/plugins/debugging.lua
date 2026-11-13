return {
	{
		"mfussenegger/nvim-dap",
		keys = {
			{
				"<leader>db",
				function()
					require("dap").toggle_breakpoint()
				end,
				desc = "Breakpoint",
			},
			{
				"<F5>",
				function()
					require("dap").continue()
				end,
				desc = "Debug continue",
			},
			{
				"<F10>",
				function()
					require("dap").step_over()
				end,
				desc = "Step over",
			},
			{
				"<F11>",
				function()
					require("dap").step_into()
				end,
				desc = "Step into",
			},
			{
				"<F12>",
				function()
					require("dap").step_out()
				end,
				desc = "Step out",
			},
			{
				"<leader>dr",
				function()
					require("dap").repl.toggle()
				end,
				desc = "Debug REPL",
			},
			{
				"<leader>du",
				function()
					require("dapui").toggle()
				end,
				desc = "Debug UI",
			},
		},
		dependencies = { "rcarriga/nvim-dap-ui", "nvim-neotest/nvim-nio" },
		config = function()
			local dap = require("dap")
			local python = vim.g.dotfiles_root .. "/.tools/python/bin/python"
			dap.adapters.python = { type = "executable", command = python, args = { "-m", "debugpy.adapter" } }
			dap.configurations.python = {
				{
					type = "python",
					request = "launch",
					name = "Current Python file",
					program = "${file}",
					console = "integratedTerminal",
					pythonPath = function()
						local env = vim.env.VIRTUAL_ENV
						if env then
							return env .. "/bin/python"
						end
						local root = vim.fs.root(0, { "pyproject.toml", ".git" }) or vim.fn.getcwd()
						if vim.fn.executable(root .. "/.venv/bin/python") == 1 then
							return root .. "/.venv/bin/python"
						end
						return python
					end,
				},
			}
			dap.adapters["pwa-node"] = {
				type = "server",
				host = "127.0.0.1",
				port = "${port}",
				executable = {
					command = "node",
					args = {
						vim.g.dotfiles_root .. "/.tools/debugger/js-debug/src/dapDebugServer.js",
						"${port}",
						"127.0.0.1",
					},
				},
			}
			for _, ft in ipairs({ "javascript", "typescript", "javascriptreact", "typescriptreact" }) do
				dap.configurations[ft] = {
					{
						type = "pwa-node",
						request = "launch",
						name = "Current Node file",
						program = "${file}",
						cwd = "${workspaceFolder}",
						sourceMaps = true,
						console = "integratedTerminal",
					},
					{
						type = "pwa-node",
						request = "attach",
						name = "Attach Node (--inspect)",
						processId = require("dap.utils").pick_process,
						cwd = "${workspaceFolder}",
						sourceMaps = true,
					},
				}
			end
			local ui = require("dapui")
			ui.setup()
			dap.listeners.after.event_initialized["dotfiles"] = function()
				ui.open()
			end
			dap.listeners.before.event_terminated["dotfiles"] = function()
				ui.close()
			end
			dap.listeners.before.event_exited["dotfiles"] = function()
				ui.close()
			end
		end,
	},
}
