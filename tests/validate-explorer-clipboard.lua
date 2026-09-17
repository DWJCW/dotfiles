-- Exercise the real Snacks action while capturing terminal output instead of
-- replacing the user's clipboard. Run with the installed LazyVim configuration.
local function validate()
  local action = LazyVim.opts("snacks.nvim").picker.actions.explorer_yank
  assert(type(action) == "function", "SSH explorer clipboard action is missing")
  local old_ssh, old_clipboard = vim.env.SSH_CONNECTION, vim.o.clipboard
  local old_send, old_notify = vim.api.nvim_ui_send, Snacks.notify.info
  local old_register = vim.fn.getreginfo('"')
  local sent, cleared = {}, 0
  vim.api.nvim_ui_send = function(data) sent[#sent + 1] = data end
  Snacks.notify.info = function() end
  vim.o.clipboard = ""
  local paths = { "/tmp/example file.tex", "/tmp/中文路径.md" }
  local picker = {
    selected = function() return { { file = paths[1] }, { file = paths[2] } } end,
    list = { set_selected = function() cleared = cleared + 1 end },
  }
  local ok, err = xpcall(function()
    vim.env.SSH_CONNECTION = "test ssh connection"
    action(picker)
    assert(vim.deep_equal(vim.fn.getreg('"', 1, true), paths), "internal paths changed")
    assert(cleared == 1, "multi-selection was not cleared")
    assert(#sent == 1, "expected one OSC 52 clipboard write")
    local payload = sent[1]:match("\027%]52;c;([A-Za-z0-9+/=]+)\027\\")
    assert(payload and vim.base64.decode(payload) == table.concat(paths, "\n"), "wrong OSC 52 payload")
    vim.env.SSH_CONNECTION = nil
    action(picker)
    assert(#sent == 1, "local yanks should keep their native clipboard behavior")
  end, debug.traceback)
  vim.env.SSH_CONNECTION, vim.o.clipboard = old_ssh, old_clipboard
  vim.api.nvim_ui_send, Snacks.notify.info = old_send, old_notify
  vim.fn.setreg('"', old_register)
  assert(ok, err)
  print("PASS: SSH explorer y sends Unicode/multiple paths through OSC 52 and preserves local behavior")
end
local ok, err = xpcall(validate, debug.traceback)
if not ok then
  vim.api.nvim_err_writeln(err)
  vim.cmd("cquit 1")
end
