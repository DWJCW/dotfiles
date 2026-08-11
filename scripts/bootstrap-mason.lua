local timeout_ms = tonumber(os.getenv("NVIM_BOOTSTRAP_MASON_TIMEOUT_MS")) or 900000

require("lazy").load({ plugins = { "mason.nvim" } })

local registry = require("mason-registry")
local tools = vim.deepcopy(LazyVim.opts("mason.nvim").ensure_installed or {})
tools = vim.fn.uniq(vim.fn.sort(tools))

-- The normal LazyVim setup starts Mason installs asynchronously. A bootstrap
-- must keep the event loop alive until those jobs finish instead of quitting
-- Neovim and letting Mason terminate them.
registry.refresh()
local finished = vim.wait(timeout_ms, function()
	for _, name in ipairs(tools) do
		local ok, pkg = pcall(registry.get_package, name)
		if ok and pkg:is_installing() then
			return false
		end
	end
	return true
end, 100)
assert(finished, ("timed out after %dms waiting for Mason installs"):format(timeout_ms))

local missing = {}
for _, name in ipairs(tools) do
	if not registry.is_installed(name) then
		missing[#missing + 1] = name
	end
end

if #missing > 0 then
	vim.cmd("MasonInstall " .. table.concat(missing, " "))
end

for _, name in ipairs(tools) do
	assert(registry.is_installed(name), "Mason package was not installed: " .. name)
end

print(("Installed all %d configured Mason tools"):format(#tools))
