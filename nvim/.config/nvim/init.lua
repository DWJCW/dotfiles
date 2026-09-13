-- Resolve the supported platform before plugin startup so invalid overrides
-- fail fast instead of surfacing only when a lazy-loaded plugin is opened.
local platform_ok, platform_error = pcall(require, "config.platform")
if not platform_ok then
  vim.api.nvim_err_writeln(tostring(platform_error))
  vim.cmd("cquit 64")
  return
end

-- bootstrap lazy.nvim, LazyVim and your plugins
require("config.lazy")
