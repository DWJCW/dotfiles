require("lazy").load({ plugins = { "nvim-treesitter" } })

local treesitter = require("nvim-treesitter")
local languages = vim.deepcopy(LazyVim.opts("nvim-treesitter").ensure_installed or {})
languages = vim.fn.uniq(vim.fn.sort(languages))

local installed = {}
for _, language in ipairs(treesitter.get_installed("parsers")) do
	installed[language] = true
end

local missing = vim.tbl_filter(function(language)
	return not installed[language]
end, languages)
assert(#missing == 0, "configured Treesitter parsers are missing: " .. table.concat(missing, ", "))
print(("PASS: all %d configured Treesitter parsers are installed"):format(#languages))
