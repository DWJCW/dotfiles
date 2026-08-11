local lockfile = assert(os.getenv("NVIM_LOCKFILE"), "NVIM_LOCKFILE is required")
local plugin = assert(os.getenv("NVIM_LAZY_PLUGIN"), "NVIM_LAZY_PLUGIN is required")

local handle = assert(io.open(lockfile, "rb"))
local lock = vim.json.decode(handle:read("*a"))
handle:close()

local pin = assert(lock[plugin], plugin .. " is not pinned in " .. lockfile)
assert(
	type(pin.commit) == "string" and pin.commit:match("^[0-9a-f]+$") and #pin.commit == 40,
	plugin .. " has an invalid commit pin"
)
io.write(pin.commit)
