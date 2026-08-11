require("lazy").load({ plugins = { "mason.nvim" } })

local registry = require("mason-registry")
local tools = vim.deepcopy(LazyVim.opts("mason.nvim").ensure_installed or {})
tools = vim.fn.uniq(vim.fn.sort(tools))

local missing = {}
for _, name in ipairs(tools) do
	if not registry.is_installed(name) then
		missing[#missing + 1] = name
	end
end

assert(#missing == 0, "configured Mason packages are missing: " .. table.concat(missing, ", "))
print(("PASS: all %d configured Mason tools are installed"):format(#tools))
