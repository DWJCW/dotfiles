local timeout_ms = tonumber(os.getenv("NVIM_BOOTSTRAP_TREESITTER_TIMEOUT_MS")) or 900000
local max_attempts = 3

require("lazy").load({ plugins = { "nvim-treesitter" } })

local treesitter = require("nvim-treesitter")
local languages = vim.deepcopy(LazyVim.opts("nvim-treesitter").ensure_installed or {})
languages = vim.fn.uniq(vim.fn.sort(languages))

local function missing_languages()
	local installed = {}
	for _, language in ipairs(treesitter.get_installed("parsers")) do
		installed[language] = true
	end

	return vim.tbl_filter(function(language)
		return not installed[language]
	end, languages)
end

for _ = 1, max_attempts do
	local missing = missing_languages()
	if #missing == 0 then
		break
	end

	local ok = treesitter.install(missing, { summary = true }):wait(timeout_ms)
	if not ok then
		vim.api.nvim_err_writeln("Treesitter parser install was incomplete; retrying")
	end
end

local missing = missing_languages()
assert(#missing == 0, "configured Treesitter parsers are missing: " .. table.concat(missing, ", "))
print(("Installed all %d configured Treesitter parsers"):format(#languages))
