local lockfile = assert(os.getenv("NVIM_LOCKFILE"), "NVIM_LOCKFILE is required")
local handle = assert(io.open(lockfile, "rb"))
local contents = handle:read("*a")
handle:close()

local lock = vim.json.decode(contents)
assert(type(lock) == "table", "lazy-lock.json must contain a JSON object")
assert(lock.LazyVim, "lazy-lock.json must pin LazyVim")
assert(lock["lazy.nvim"], "lazy-lock.json must pin lazy.nvim")

local plugin_count = 0
for name, pin in pairs(lock) do
	plugin_count = plugin_count + 1
	assert(type(pin) == "table", name .. " lock entry must be an object")
	assert(type(pin.branch) == "string" and pin.branch ~= "", name .. " must pin a branch")
	assert(
		type(pin.commit) == "string" and pin.commit:match("^[0-9a-f]+$") and #pin.commit == 40,
		name .. " must pin a full 40-character commit"
	)
end

assert(plugin_count >= 2, "lazy-lock.json must contain plugin pins")
print(("PASS: lazy-lock.json pins %d plugins, including LazyVim and lazy.nvim"):format(plugin_count))
