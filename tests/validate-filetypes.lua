-- An empty startup does not load filetype plugins (notably VimTeX's version
-- check). Open representative files so incompatible locked plugins fail CI.
local root = vim.fn.tempname() .. "-dotfiles-filetypes"
local buffers = {}
local function validate()
  vim.fn.mkdir(root, "p")
  local fixtures = {
    { "sample.tex", { "\\documentclass{article}", "\\begin{document}", "test", "\\end{document}" }, "tex" },
    { "sample.py", { "def answer():", "    return 42" }, "python" },
    { "sample.cpp", { "int main() { return 0; }" }, "cpp" },
    { "CMakeLists.txt", { "cmake_minimum_required(VERSION 3.20)", "project(test)" }, "cmake" },
    { "sample.md", { "# Test" }, "markdown" },
    { "sample.lua", { "return {}" }, "lua" },
    { "sample.sh", { "#!/bin/bash", "echo test" }, "sh" },
  }
  for _, fixture in ipairs(fixtures) do
    local path = root .. "/" .. fixture[1]
    vim.fn.writefile(fixture[2], path)
    vim.cmd("edit " .. vim.fn.fnameescape(path))
    buffers[#buffers + 1] = vim.api.nvim_get_current_buf()
    assert(vim.bo.filetype == fixture[3], "wrong filetype for " .. fixture[1])
    if fixture[3] == "tex" then
      assert(vim.b.vimtex, "VimTeX did not initialize for a LaTeX document")
    end
  end
  print("PASS: LaTeX, Python, C++, CMake, Markdown, Lua and shell files open successfully")
end
local ok, err = xpcall(validate, debug.traceback)
for _, buffer in ipairs(buffers) do
  for _, client in ipairs(vim.lsp.get_clients({ bufnr = buffer })) do client:stop(true) end
  pcall(vim.api.nvim_buf_delete, buffer, { force = true })
end
vim.fn.delete(root, "rf")
if not ok then
  vim.api.nvim_err_writeln(err)
  vim.cmd("cquit 1")
end
-- lazy.nvim and nvim-ts-autotag deliberately pcall deletion of absent maps.
-- That handled E31 still sets v:errmsg; all unhandled filetype errors above
-- already exit nonzero through xpcall. Do not confuse cleanup with a failure.
if vim.v.errmsg == "E31: No such mapping" then vim.v.errmsg = "" end
