local languages = {
	"python",
	"javascript",
	"typescript",
	"tsx",
	"lua",
	"latex",
	"json",
	"jsonc",
	"css",
	"html",
	"markdown",
	"markdown_inline",
	"vim",
	"vimdoc",
	"query",
}
require("nvim-treesitter").install(languages):wait(300000)
for _, lang in ipairs(languages) do
	local ok, err = pcall(vim.treesitter.language.add, lang)
	if not ok then
		error("Parser " .. lang .. " unavailable: " .. tostring(err))
	end
end
