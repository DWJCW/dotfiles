local lockfile = assert(os.getenv("NVIM_LOCKFILE"), "NVIM_LOCKFILE is required")
local lazy_root = assert(os.getenv("NVIM_LAZY_ROOT"), "NVIM_LAZY_ROOT is required")

local handle = assert(io.open(lockfile, "rb"))
local lock = vim.json.decode(handle:read("*a"))
handle:close()

local errors = {}
local plugin_count = 0
for name, pin in pairs(lock) do
	plugin_count = plugin_count + 1
	local plugin_dir = lazy_root .. "/" .. name
	local result = vim.system({ "git", "-C", plugin_dir, "rev-parse", "HEAD" }, { text = true }):wait()
	local installed = result.code == 0 and vim.trim(result.stdout or "") or nil
	if not installed then
		errors[#errors + 1] = name .. ": checkout is missing"
	elseif installed ~= pin.commit then
		errors[#errors + 1] = name .. ": installed " .. installed .. ", locked " .. pin.commit
	end
end

if #errors > 0 then
	error("plugin lock verification failed:\n  " .. table.concat(errors, "\n  "))
end

print(("PASS: all %d installed plugins match lazy-lock.json"):format(plugin_count))
