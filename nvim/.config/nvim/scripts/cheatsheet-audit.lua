vim.cmd("doautocmd User VeryLazy")
local ok, summary = require("config.cheatsheet").run_full({ generate = false })
print(("LazyVim cheat-sheet audit: %d/%d passed"):format(summary.passed, summary.total))
print("Report: " .. summary.report)
if ok then
  vim.cmd("qa!")
else
  vim.cmd("cquit")
end
