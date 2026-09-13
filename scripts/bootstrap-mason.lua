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
	-- Call Mason's package API directly. Running :MasonInstall from inside
	-- vim.cmd() lets installer output (notably npm warnings) re-enter the Ex
	-- command parser and produce a spurious E5108 in headless mode.
	for _, name in ipairs(missing) do
		local pkg = assert(registry.get_package(name), "Mason package is missing from the registry: " .. name)
		local done = false
		local success = false
		local result

		pkg:install({}, function(ok, value)
			success = ok
			result = value
			done = true
		end)

		local finished = vim.wait(timeout_ms, function()
			return done
		end, 100)
		assert(finished, ("timed out after %dms installing Mason package %s"):format(timeout_ms, name))
		assert(success, ("Mason package failed to install %s: %s"):format(name, tostring(result)))
	end
end

for _, name in ipairs(tools) do
	assert(registry.is_installed(name), "Mason package was not installed: " .. name)
end

print(("Installed all %d configured Mason tools"):format(#tools))
