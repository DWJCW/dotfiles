local function assert_contains(items, expected, label)
	assert(vim.tbl_contains(items or {}, expected), ("%s is missing %s"):format(label, expected))
end

local function validate()
	local plugins = require("lazy.core.config").plugins
	assert(plugins["clangd_extensions.nvim"], "clangd_extensions.nvim spec is missing")
	assert(plugins["cmake-tools.nvim"], "cmake-tools.nvim spec is missing")

	local lsp = LazyVim.opts("nvim-lspconfig")
	assert(lsp.servers and lsp.servers.clangd, "clangd LSP is not configured")
	assert(lsp.servers and lsp.servers.neocmake, "neocmake LSP is not configured")

	local treesitter = LazyVim.opts("nvim-treesitter")
	assert_contains(treesitter.ensure_installed, "cpp", "Treesitter parsers")
	assert_contains(treesitter.ensure_installed, "cmake", "Treesitter parsers")

	local mason = LazyVim.opts("mason.nvim")
	for _, tool in ipairs({ "clangd", "cmakelang", "cmakelint", "neocmakelsp" }) do
		assert_contains(mason.ensure_installed, tool, "Mason tools")
	end
end

local ok, err = xpcall(validate, debug.traceback)
if not ok then
	vim.api.nvim_err_writeln(err)
	vim.cmd("cquit 1")
end

print("PASS: clangd and CMake development toolchains are configured")
