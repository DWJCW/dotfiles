vim.cmd("doautocmd User VeryLazy")
-- Wrap in pcall: an unexpected error must never leave this headless process
-- waiting at a command-line prompt (which hung :NvimCheatsheetAudit before).
-- Exit code 0 on success, non-zero on any failure, with the reason on stderr.
-- run_full returns (passed==total, { passed, total, report }); pcall adds one more.
local ok, passed, summary = pcall(require("config.cheatsheet").run_full, { generate = false, seal = true })
if not ok then
  io.stderr:write(("LazyVim cheat-sheet audit FAILED: %s\n"):format(tostring(passed)))
  vim.cmd("cquit")
  return
end
print(("LazyVim cheat-sheet audit: %d/%d passed"):format(summary.passed, summary.total))
print("Report: " .. summary.report)
-- A passing audit seals the manifest so the startup drift warning clears;
-- a failing one keeps the previous seal and reports via cquit.
vim.cmd(passed and "qa!" or "cquit")
