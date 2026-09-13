local M = {}

local uv = vim.uv or vim.loop
local requested = vim.env.DOTFILES_PLATFORM

local function resolve_platform(value)
  if value == nil or value == "" then value = "auto" end

  if value == "linux" or value == "macos" then return value end
  if value ~= "auto" then
    error(("config.platform: invalid DOTFILES_PLATFORM=%q; expected auto, linux, or macos"):format(value))
  end

  local system_name = uv.os_uname().sysname
  if system_name == "Linux" then return "linux" end
  if system_name == "Darwin" then return "macos" end
  error(("config.platform: unsupported operating system %q; only Linux and macOS are supported"):format(system_name))
end

M.requested = requested
if M.requested == nil or M.requested == "" then M.requested = "auto" end
M.name = resolve_platform(requested)
M.current = M.name
M.platform = M.name

function M.is_linux()
  return M.name == "linux"
end

function M.is_macos()
  return M.name == "macos"
end

function M.command_exists(command)
  return type(command) == "string" and command ~= "" and vim.fn.executable(command) == 1
end

M.has_command = M.command_exists

function M.command_path(command)
  if not M.command_exists(command) then return nil end
  local path = vim.fn.exepath(command)
  return path ~= "" and path or command
end

local skim_cache

local function skim_app_path_exists()
  local application_paths = {
    vim.fn.expand("~/Applications/Skim.app"),
    "/Applications/Skim.app",
  }
  for _, path in ipairs(application_paths) do
    if vim.fn.isdirectory(path) == 1 then return true end
  end
  return false
end

function M.skim_available()
  if not M.is_macos() then return false end
  if skim_cache ~= nil then return skim_cache end

  if M.command_exists("skim") or skim_app_path_exists() then
    skim_cache = true
    return skim_cache
  end

  -- A Skim application may live outside the two conventional locations.
  -- Ask macOS directly, but only after the platform has been resolved as
  -- macOS. This keeps Linux completely free of macOS probes.
  if not M.command_exists("osascript") then
    skim_cache = false
    return skim_cache
  end
  local ok, result = pcall(function()
    return vim.system({ "osascript", "-l", "JavaScript", "-e", 'Application("Skim").id()' }, { text = true }):wait()
  end)
  skim_cache = ok and result.code == 0 and (result.stdout or ""):find("net.sourceforge.skim-app", 1, true) ~= nil
  return skim_cache
end

local function shell(command_line)
  local result = vim.system(command_line, { text = true }):wait()
  return result.code == 0, vim.trim(result.stdout or ""), vim.trim(result.stderr or "")
end

function M.skim_inverse_search()
  if not M.is_macos() then
    return {
      applicable = false,
      ok = true,
      detail = "Linux：Skim 仅适用于 macOS，已跳过 defaults 检查",
    }
  end

  if not M.skim_available() then
    return {
      applicable = true,
      available = false,
      ok = false,
      detail = "macOS：未检测到 Skim，未执行 defaults 检查",
    }
  end

  if not M.command_exists("defaults") then
    return {
      applicable = true,
      available = true,
      ok = false,
      detail = "macOS：defaults 不可用，未检查 Skim 反向搜索设置",
    }
  end

  local preset_ok, preset = shell({ "defaults", "read", "net.sourceforge.skim-app.skim", "SKTeXEditorPreset" })
  local command_ok, editor = shell({ "defaults", "read", "net.sourceforge.skim-app.skim", "SKTeXEditorCommand" })
  local args_ok, args = shell({ "defaults", "read", "net.sourceforge.skim-app.skim", "SKTeXEditorArguments" })
  local inverse = args_ok and args:find("VimtexInverseSearch", 1, true) ~= nil
  local pass = vim.g.vimtex_view_method == "skim"
    and vim.g.vimtex_view_skim_sync == 1
    and preset_ok and preset == "Custom"
    and command_ok and editor:match("nvim$") ~= nil
    and inverse
  return {
    applicable = true,
    available = true,
    ok = pass,
    detail = ("Skim preset=%s, editor=%s, inverse=%s"):format(preset, editor, tostring(inverse)),
  }
end

local pdf_viewer_cache

function M.pdf_viewer()
  if pdf_viewer_cache then return vim.deepcopy(pdf_viewer_cache) end

  if M.is_macos() then
    if M.skim_available() then
      pdf_viewer_cache = {
        available = true,
        id = "skim",
        method = "skim",
        command = M.command_path("skim") or "skim",
        label = "Skim",
      }
    elseif M.command_exists("open") then
      pdf_viewer_cache = {
        available = true,
        id = "open",
        method = "general",
        command = M.command_path("open"),
        label = "macOS open",
      }
    end
  else
    for _, candidate in ipairs({
      { id = "zathura", method = "zathura", label = "Zathura" },
      { id = "okular", method = "general", label = "Okular" },
      { id = "xdg-open", method = "general", label = "xdg-open" },
    }) do
      if M.command_exists(candidate.id) then
        pdf_viewer_cache = {
          available = true,
          id = candidate.id,
          method = candidate.method,
          command = M.command_path(candidate.id),
          label = candidate.label,
        }
        break
      end
    end
  end

  if not pdf_viewer_cache then
    pdf_viewer_cache = {
      available = false,
      id = "none",
      method = "general",
      command = nil,
      fallback_command = M.is_macos() and "open" or "xdg-open",
      label = "none",
      warning = M.is_macos()
        and "未检测到可用的 macOS PDF 查看器；VimTeX 仍可启动。"
        or "未检测到 PDF 查看器；VimTeX 仍可启动。请安装 zathura、okular 或 xdg-open。",
    }
  end
  return vim.deepcopy(pdf_viewer_cache)
end

function M.has_pdf_viewer()
  return M.pdf_viewer().available
end

M.get_platform = function()
  return M.name
end
M.is_command_available = M.command_exists
M.get_pdf_viewer = M.pdf_viewer
M.is_skim_available = M.skim_available

return M
