local M = {}
function M.settings()
	local path = vim.g.dotfiles_root .. "/.state/appearance/settings.json"
	local ok, value = pcall(function()
		return vim.json.decode(table.concat(vim.fn.readfile(path), "\n"))
	end)
	return ok and value or { theme = "poimandres" }
end
function M.palette()
	local path = vim.g.dotfiles_root .. "/config/appearance/presets.json"
	local presets = vim.json.decode(table.concat(vim.fn.readfile(path), "\n"))
	return presets[M.settings().theme] or presets.poimandres
end
function M.apply()
	local theme = M.settings().theme
	if theme == "tokyo-night-moon" then
		require("tokyonight").setup({
			style = "moon",
			transparent = true,
			styles = { comments = { italic = true }, keywords = { italic = true } },
		})
	elseif theme == "catppuccin-mocha" then
		require("catppuccin").setup({ flavour = "mocha", transparent_background = true })
	elseif theme == "rose-pine-moon" then
		require("rose-pine").setup({ variant = "moon", styles = { transparency = true } })
	elseif theme == "kanagawa-wave" or theme == "kanagawa-dragon" then
		require("kanagawa").setup({ transparent = true })
	else
		require("poimandres").setup({ disable_background = true, disable_float_background = false })
	end
	local ok, err = pcall(vim.cmd.colorscheme, M.palette().scheme)
	if not ok then
		vim.notify("Theme unavailable; run ./install.sh --plugins. " .. tostring(err), vim.log.levels.WARN)
		vim.cmd.colorscheme("poimandres")
	end
end
return M
