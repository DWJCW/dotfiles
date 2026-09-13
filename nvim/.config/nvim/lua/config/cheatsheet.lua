local M = {}

local platform = require("config.platform")
local config_dir = vim.fn.stdpath("config")
local report_path = config_dir .. "/CHEATSHEET-AUDIT.md"
local manifest_path = config_dir .. "/cheatsheet-audit.json"
local markdown_path = config_dir .. "/CHEATSHEET.zh-CN.md"
local html_path = config_dir .. "/LazyVim-Cheatsheet-iPadPro.html"
local image_path = config_dir .. "/LazyVim-Cheatsheet-iPadPro.png"

local function map(context, lhs, desc, rhs, mode)
  return { kind = "map", context = context, lhs = lhs, desc = desc, rhs = rhs, mode = mode or "n" }
end

local function command(context, name)
  return { kind = "command", context = context, command = name }
end

local function capability(name, context, extra)
  return vim.tbl_extend("force", { kind = "capability", capability = name, context = context or "global" }, extra or {})
end

local function entry(id, display, text, bindings)
  return { id = id, display = type(display) == "table" and display or { display }, text = text, bindings = bindings }
end

M.columns = {
  {
    cards = {
      {
        icon = "F", color = "cyan", title = "文件、搜索与文件树",
        rows = {
          entry("files.explorer", "Space e", "项目文件树", {
            map("global", "<leader>e", "Explorer Snacks (root dir)", "<leader>fe"),
          }),
          entry("files.find", "Space Space", "查找项目文件", {
            map("global", "<leader><space>", "Find Files (Root Dir)"),
          }),
          entry("files.find_alias", "Space f f", "同上：查找文件", {
            map("global", "<leader>ff", "Find Files (Root Dir)"),
          }),
          entry("files.grep", "Space /", "全文搜索", {
            map("global", "<leader>/", "Grep (Root Dir)"),
          }),
          entry("files.word", "Space s w", "搜索当前词/选区", {
            map("global", "<leader>sw", "Visual selection or word (Root Dir)", nil, "n"),
            map("global", "<leader>sw", "Visual selection or word (Root Dir)", nil, "x"),
          }),
          entry("files.recent", "Space f r", "最近文件", {
            map("global", "<leader>fr", "Recent"),
          }),
          entry("files.keymaps", "Space s k", "搜索所有快捷键", {
            map("global", "<leader>sk", "Keymaps"),
          }),
        },
      },
      {
        icon = "B", color = "blue", title = "Buffer、编辑分屏与 Tab", grow = true,
        rows = {
          entry("buffer.cycle_shift", "Shift h / l", "前/后一个 buffer", {
            map("global", "<S-h>", "Prev Buffer", "<cmd>BufferLineCyclePrev<cr>"),
            map("global", "<S-l>", "Next Buffer", "<cmd>BufferLineCycleNext<cr>"),
          }),
          entry("buffer.cycle_bracket", { "[ b", "] b" }, "前/后一个 buffer", {
            map("global", "[b", "Prev Buffer", "<cmd>BufferLineCyclePrev<cr>"),
            map("global", "]b", "Next Buffer", "<cmd>BufferLineCycleNext<cr>"),
          }),
          entry("buffer.pick", "Space ,", "列出并选择 buffer", {
            map("global", "<leader>,", "Buffers"),
          }),
          entry("buffer.delete", "Space b d", "关闭当前 buffer", {
            map("global", "<leader>bd", "Delete Buffer"),
          }),
          entry("buffer.delete_other", "Space b o", "关闭其他 buffer", {
            map("global", "<leader>bo", "Delete Other Buffers"),
          }),
          entry("window.move", "Ctrl h/j/k/l", "移动到相邻编辑分屏", {
            map("global", "<C-h>", "Go to Left Window", "<C-w>h"),
            map("global", "<C-j>", "Go to Lower Window", "<C-w>j"),
            map("global", "<C-k>", "Go to Upper Window", "<C-w>k"),
            map("global", "<C-l>", "Go to Right Window", "<C-w>l"),
          }),
          entry("window.split", { "Space |", "Space -" }, "左右/上下打开编辑分屏", {
            map("global", "<leader>|", "Split Window Right", "<C-W>v"),
            map("global", "<leader>-", "Split Window Below", "<C-W>s"),
          }),
          entry("window.quit_tool", "q", "关闭文件树/选择器/帮助窗", {
            map("help", "q", "Quit buffer"),
            capability("snacks_picker_q", "global"),
          }),
          entry("window.delete_split", "Space w d", "关闭当前编辑分屏", {
            map("global", "<leader>wd", "Delete Window", "<C-W>c"),
          }),
          entry("tab.new", "Space Tab Tab", "新建 tabpage", {
            map("global", "<leader><tab><tab>", "New Tab", "<cmd>tabnew<cr>"),
          }),
          entry("tab.cycle", { "Space Tab [", "Space Tab ]" }, "前/后一个 tabpage", {
            map("global", "<leader><tab>[", "Previous Tab", "<cmd>tabprevious<cr>"),
            map("global", "<leader><tab>]", "Next Tab", "<cmd>tabnext<cr>"),
          }),
        },
      },
    },
    note = '<strong>窗口要分清：</strong><code>Space | / Space -</code> 打开编辑分屏，<code>Space w d</code> 关闭编辑分屏；<code>q</code> 关闭文件树、选择器、help 等工具窗口；<code>Space b d</code> 关闭文件 buffer。',
  },
  {
    cards = {
      {
        icon = "T", color = "green", title = "LaTeX / VimTeX",
        rows = {
          entry("tex.compile", "\\ l l", "启动/停止持续编译", {
            map("tex", "<localleader>ll", nil, "<plug>(vimtex-compile)"),
          }),
          entry("tex.view", "\\ l v", "Skim 正向跳转", {
            map("tex", "<localleader>lv", nil, "<plug>(vimtex-view)"),
          }),
          entry("tex.errors", "\\ l e", "查看编译错误", {
            map("tex", "<localleader>le", nil, "<plug>(vimtex-errors)"),
          }),
          entry("tex.output", "\\ l o", "完整编译输出", {
            map("tex", "<localleader>lo", nil, "<plug>(vimtex-compile-output)"),
          }),
          entry("tex.info", "\\ l i", "VimTeX 项目信息", {
            map("tex", "<localleader>li", nil, "<plug>(vimtex-info)"),
          }),
          entry("tex.toc", "\\ l t", "LaTeX 目录", {
            map("tex", "<localleader>lt", nil, "<plug>(vimtex-toc-open)"),
          }),
          entry("tex.stop", "\\ l k", "停止编译器", {
            map("tex", "<localleader>lk", nil, "<plug>(vimtex-stop)"),
          }),
          entry("tex.clean", "\\ l c", "清理普通编译产物", {
            map("tex", "<localleader>lc", nil, "<plug>(vimtex-clean)"),
          }),
          entry("tex.inverse", "⇧⌘ + 点击 PDF", "Skim 反向跳回源码", {
            capability("skim_inverse", "tex"),
          }),
        },
      },
      {
        icon = "C", color = "purple", title = "编辑、诊断与 LSP", grow = true,
        rows = {
          entry("edit.save", "Ctrl s", "保存", {
            map("global", "<C-s>", "Save File", "<cmd>w<cr><esc>"),
          }),
          entry("edit.format", "Space c f", "格式化文件/选区", {
            map("global", "<leader>cf", "Format", nil, "n"),
            map("global", "<leader>cf", "Format", nil, "x"),
          }),
          entry("lsp.definition", "g d", "跳到定义", {
            map("python", "gd", "Goto Definition"),
          }),
          entry("lsp.references", "g r", "查找引用", {
            map("python", "gr", "References"),
          }),
          entry("lsp.hover", "K", "光标处文档说明", {
            map("python", "K", "Hover"),
          }),
          entry("lsp.rename", "Space c r", "重命名符号", {
            map("python", "<leader>cr", "Rename"),
          }),
          entry("lsp.action", "Space c a", "Code Action", {
            map("python", "<leader>ca", "Code Action", nil, "n"),
            map("python", "<leader>ca", "Code Action", nil, "x"),
          }),
          entry("diagnostic.cycle", { "[ d", "] d" }, "前/后一个诊断", {
            map("global", "[d", "Prev Diagnostic"),
            map("global", "]d", "Next Diagnostic"),
          }),
          entry("diagnostic.list", "Space x x", "项目诊断列表", {
            map("global", "<leader>xx", "Diagnostics (Trouble)", "<cmd>Trouble diagnostics toggle<cr>"),
          }),
          entry("python.venv", "Space c v", "Python 选择虚拟环境", {
            map("python", "<leader>cv", "Select VirtualEnv", "<cmd>:VenvSelect<cr>"),
          }),
        },
      },
    },
    note = '<strong>当前工具链：</strong>Pyright + Ruff · Texlab + VimTeX · Marksman · JSON/YAML/TOML/Bash LSP。AI、DAP 和测试框架未启用。',
  },
  {
    cards = {
      {
        icon = "M", color = "yellow", title = "Markdown 与图片",
        rows = {
          entry("markdown.preview", "Space c p", "浏览器 Markdown 预览", {
            map("markdown", "<leader>cp", "Markdown Preview", "<cmd>MarkdownPreviewToggle<cr>"),
          }),
          entry("markdown.render", "Space u m", "Nvim 内 Markdown 美化", {
            map("markdown", "<leader>um", "Toggle Render Markdown"),
          }),
          entry("image.open", ":edit 图.png", "Nvim 内预览图片", {
            capability("snacks_image", "global", { format = "png" }),
          }),
          entry("pdf.open", ":edit 文档.pdf", "Nvim 内快速看 PDF", {
            capability("snacks_image", "global", { format = "pdf" }),
          }),
          entry("system.open", "g x", "用系统应用打开目标", {
            map("global", "gx", nil, nil, "n"),
          }),
        },
      },
      {
        icon = "G", color = "red", title = "Git 与终端",
        rows = {
          entry("git.lazygit", "Space g g", "项目根目录 Lazygit", {
            map("global", "<leader>gg", "Lazygit (Root Dir)"),
          }),
          entry("git.status", "Space g s", "Git 状态", {
            map("global", "<leader>gs", "Git Status"),
          }),
          entry("git.hunk_cycle", { "[ h", "] h" }, "前/后一个修改块", {
            map("git", "[h", "Prev Hunk"),
            map("git", "]h", "Next Hunk"),
          }),
          entry("git.hunk_preview", "Space g h p", "预览当前修改块", {
            map("git", "<leader>ghp", "Preview Hunk Inline"),
          }),
          entry("terminal.root", "Space f t", "项目根目录终端", {
            map("global", "<leader>ft", "Terminal (Root Dir)"),
          }),
          entry("terminal.toggle", "Ctrl /", "显示/隐藏浮动终端", {
            map("global", "<C-/>", "Terminal (Root Dir)"),
          }),
        },
      },
      {
        icon = "?", color = "cyan", title = "帮助与维护", grow = true,
        rows = {
          entry("help.which_key", "Space（稍等）", "which-key 提示", {
            capability("which_key", "global"),
          }),
          entry("help.buffer_keys", "Space ?", "当前 buffer 快捷键", {
            map("global", "<leader>?", "Buffer Keymaps (which-key)"),
          }),
          entry("help.cheatsheet", ":NvimCheatsheetImage", "打开本图片", {
            command("global", "NvimCheatsheetImage"),
          }),
          entry("help.audit", ":NvimCheatsheetAudit", "审计全部小抄键位", {
            command("global", "NvimCheatsheetAudit"),
          }),
          entry("help.lazy", ":Lazy", "插件管理", {
            command("global", "Lazy"),
          }),
          entry("help.mason", ":Mason", "语言工具管理", {
            command("global", "Mason"),
          }),
          entry("help.health", ":checkhealth", "健康检查", {
            command("global", "checkhealth"),
          }),
          entry("help.vimtex", ":VimtexInfo", "LaTeX 故障排查", {
            command("tex", "VimtexInfo"),
          }),
        },
      },
    },
    note = '<strong>防漂移：</strong>配置或插件锁文件变化后，启动 Nvim 会提醒。运行 <code>:NvimCheatsheetAudit</code> 可逐项复核；有失败时不会覆盖小抄。',
  },
}

M.quickbar = {
  { label = "文件树", id = "files.explorer" },
  { label = "找文件", id = "files.find" },
  { label = "全文搜索", id = "files.grep" },
  { label = "切文件", id = "buffer.cycle_shift" },
  { label = "LaTeX 编译", id = "tex.compile" },
  { label = "Lazygit", id = "git.lazygit" },
}

local function all_entries()
  local entries = {}
  for _, column in ipairs(M.columns) do
    for _, card in ipairs(column.cards) do
      for _, row in ipairs(card.rows) do
        entries[#entries + 1] = row
      end
    end
  end
  return entries
end

local function entry_by_id(id)
  for _, item in ipairs(all_entries()) do
    if item.id == id then return item end
  end
end

local function expand(lhs)
  lhs = lhs:gsub("<leader>", vim.g.mapleader or "\\")
  lhs = lhs:gsub("<localleader>", vim.g.maplocalleader or "\\")
  return lhs
end

local function read_text(path)
  local file = io.open(path, "rb")
  if not file then return nil end
  local text = file:read("*a")
  file:close()
  return text
end

local function write_text(path, text)
  local file = assert(io.open(path, "wb"))
  file:write(text)
  file:close()
end

local function trim(text)
  return (text or ""):gsub("^%s+", ""):gsub("%s+$", "")
end

local function shell(command_line)
  local result = vim.system(command_line, { text = true }):wait()
  return result.code == 0, trim(result.stdout), trim(result.stderr)
end

local function set_context(contexts, name)
  local buffer = contexts[name]
  if buffer and vim.api.nvim_buf_is_valid(buffer) then
    vim.api.nvim_set_current_buf(buffer)
  end
end

local function get_map(binding, contexts)
  set_context(contexts, binding.context)
  return vim.fn.maparg(expand(binding.lhs), binding.mode or "n", false, true)
end

local callback_sources = {
  ["Find Files (Root Dir)"] = "/lazy/LazyVim/lua/lazyvim/util/pick.lua",
  ["Grep (Root Dir)"] = "/lazy/LazyVim/lua/lazyvim/util/pick.lua",
  ["Visual selection or word (Root Dir)"] = "/lazy/LazyVim/lua/lazyvim/util/pick.lua",
  ["Recent"] = "/lazy/LazyVim/lua/lazyvim/util/pick.lua",
  ["Keymaps"] = "/lazy/LazyVim/lua/lazyvim/plugins/extras/editor/snacks_picker.lua",
  ["Buffers"] = "/lazy/LazyVim/lua/lazyvim/plugins/extras/editor/snacks_picker.lua",
  ["Delete Buffer"] = "/lazy/LazyVim/lua/lazyvim/config/keymaps.lua",
  ["Delete Other Buffers"] = "/lazy/LazyVim/lua/lazyvim/config/keymaps.lua",
  ["Quit buffer"] = "/lazy/LazyVim/lua/lazyvim/config/autocmds.lua",
  ["Format"] = "/lazy/LazyVim/lua/lazyvim/config/keymaps.lua",
  ["Goto Definition"] = "/lazy/LazyVim/lua/lazyvim/plugins/extras/editor/snacks_picker.lua",
  ["References"] = "/lazy/LazyVim/lua/lazyvim/plugins/extras/editor/snacks_picker.lua",
  ["Hover"] = "/lazy/LazyVim/lua/lazyvim/plugins/lsp/init.lua",
  ["Rename"] = "/runtime/lua/vim/lsp/buf.lua",
  ["Code Action"] = "/runtime/lua/vim/lsp/buf.lua",
  ["Prev Diagnostic"] = "/lazy/LazyVim/lua/lazyvim/config/keymaps.lua",
  ["Next Diagnostic"] = "/lazy/LazyVim/lua/lazyvim/config/keymaps.lua",
  ["Toggle Render Markdown"] = "/lazy/snacks.nvim/lua/snacks/toggle.lua",
  ["Lazygit (Root Dir)"] = "/lazy/LazyVim/lua/lazyvim/config/keymaps.lua",
  ["Git Status"] = "/lazy/LazyVim/lua/lazyvim/plugins/extras/editor/snacks_picker.lua",
  ["Prev Hunk"] = "/lazy/LazyVim/lua/lazyvim/plugins/editor.lua",
  ["Next Hunk"] = "/lazy/LazyVim/lua/lazyvim/plugins/editor.lua",
  ["Preview Hunk Inline"] = "/lazy/gitsigns.nvim/lua/gitsigns/actions.lua",
  ["Terminal (Root Dir)"] = "/lazy/LazyVim/lua/lazyvim/config/keymaps.lua",
  ["Buffer Keymaps (which-key)"] = "/lazy/LazyVim/lua/lazyvim/plugins/editor.lua",
}

local function map_result(binding, contexts)
  local actual = get_map(binding, contexts)
  if vim.tbl_isempty(actual) then
    return false, "未找到映射"
  end
  if binding.desc and actual.desc ~= binding.desc then
    return false, ("说明不匹配：期望 %q，实际 %q"):format(binding.desc, actual.desc or "")
  end
  if binding.rhs and actual.rhs ~= binding.rhs then
    return false, ("目标不匹配：期望 %q，实际 %q"):format(binding.rhs, actual.rhs or "<Lua callback>")
  end
  local target = actual.rhs and actual.rhs ~= "" and actual.rhs or "<Lua callback>"
  if actual.callback then
    local info = debug.getinfo(actual.callback, "Sl") or {}
    local expected_source = callback_sources[binding.desc]
      or (binding.lhs == "gx" and "vim/_core/defaults")
    local source = info.source or ""
    if expected_source and not source:find(expected_source, 1, true) then
      return false, ("Lua 目标来源不匹配：期望包含 %q，实际 %q"):format(expected_source, source)
    end
    target = target .. " @ " .. (info.short_src or "?") .. ":" .. tostring(info.linedefined or "?")
  end
  return true, (actual.desc and actual.desc ~= "" and actual.desc .. " → " or "") .. target
end

local function command_result(binding, contexts)
  set_context(contexts, binding.context)
  local exists = vim.fn.exists(":" .. binding.command) == 2
  return exists, exists and (":" .. binding.command .. " 已注册") or (":" .. binding.command .. " 不存在")
end

local function capability_result(binding)
  if binding.capability == "which_key" then
    local ok = pcall(require, "which-key")
    local leader_ok = vim.g.mapleader == " "
    return ok and leader_ok, ok and leader_ok and "which-key 已加载，Leader=Space" or "which-key 未加载或 Leader 不是 Space"
  end

  if binding.capability == "snacks_picker_q" then
    local ok, opts = pcall(function() return require("snacks.picker.config").get({ source = "files" }) end)
    if not ok then return false, "无法读取 Snacks picker 配置" end
    local input = opts.win.input.keys.q
    local list = opts.win.list.keys.q
    local preview = opts.win.preview.keys.q
    local pass = input == "cancel" and list == "cancel" and preview == "cancel"
    return pass, ("Snacks q：input=%s, list=%s, preview=%s"):format(tostring(input), tostring(list), tostring(preview))
  end

  if binding.capability == "snacks_image" then
    local opts = Snacks and Snacks.config and Snacks.config.image or {}
    local formats = opts.formats or {}
    local format_ok = vim.tbl_contains(formats, binding.format)
    local tools_ok = vim.fn.executable("magick") == 1 and (binding.format ~= "pdf" or vim.fn.executable("gs") == 1)
    local pass = opts.enabled == true and opts.doc and opts.doc.enabled == false and format_ok and tools_ok
    return pass, ("Snacks.image enabled=%s, doc=%s, format=%s, tools=%s"):format(
      tostring(opts.enabled), tostring(opts.doc and opts.doc.enabled), tostring(format_ok), tostring(tools_ok)
    )
  end

  if binding.capability == "skim_inverse" then
    local result = platform.skim_inverse_search()
    return result.ok, result.detail
  end

  return false, "未知 capability: " .. tostring(binding.capability)
end

local function prepare_contexts()
  local contexts = {}
  local temp_root = vim.fn.tempname() .. "-lazyvim-cheatsheet"
  vim.fn.mkdir(temp_root, "p")

  -- The audit only needs LSP attachment and keymaps. Disable recursive file
  -- watchers inside this short-lived headless process so pyright/ruff cannot
  -- exhaust macOS FSEvent handles while registering dynamic capabilities.
  local original_watchfunc = vim.lsp._watchfiles._watchfunc
  vim.lsp._watchfiles._watchfunc = function() return function() end end

  local plain = vim.api.nvim_create_buf(false, true)
  vim.bo[plain].filetype = "text"
  contexts.global = plain

  require("lazy").load({ plugins = { "markdown-preview.nvim", "render-markdown.nvim" } })
  local markdown = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_name(markdown, temp_root .. "/audit.md")
  vim.api.nvim_set_current_buf(markdown)
  vim.bo[markdown].filetype = "markdown"
  vim.cmd("doautocmd FileType markdown")
  vim.wait(200)
  contexts.markdown = markdown

  local tex_path = temp_root .. "/audit.tex"
  vim.fn.writefile({ "\\documentclass{article}", "\\begin{document}", "audit", "\\end{document}" }, tex_path)
  vim.cmd("silent edit " .. vim.fn.fnameescape(tex_path))
  vim.wait(1500, function() return vim.b.vimtex ~= nil end, 50)
  contexts.tex = vim.api.nvim_get_current_buf()

  local git_root = temp_root .. "/git"
  vim.fn.mkdir(git_root, "p")
  local git_path = git_root .. "/sample.txt"
  vim.fn.writefile({ "base" }, git_path)
  shell({ "git", "-C", git_root, "init", "-q" })
  shell({ "git", "-C", git_root, "add", "sample.txt" })
  shell({ "git", "-C", git_root, "-c", "user.name=LazyVim Audit", "-c", "user.email=audit@example.invalid", "commit", "-qm", "base" })
  vim.fn.writefile({ "base", "changed" }, git_path)
  vim.cmd("silent edit " .. vim.fn.fnameescape(git_path))
  require("lazy").load({ plugins = { "gitsigns.nvim" } })
  require("gitsigns").attach(0)
  vim.wait(2000, function() return not vim.tbl_isempty(vim.fn.maparg("[h", "n", false, true)) end, 50)
  contexts.git = vim.api.nvim_get_current_buf()

  local python_root = temp_root .. "/python"
  vim.fn.mkdir(python_root, "p")
  vim.fn.writefile({ "[tool.pyright]", 'typeCheckingMode = "basic"' }, python_root .. "/pyproject.toml")
  local python_path = python_root .. "/audit.py"
  vim.fn.writefile({ "def answer() -> int:", "    return 42", "", "answer()" }, python_path)
  vim.cmd("silent edit " .. vim.fn.fnameescape(python_path))
  vim.wait(12000, function()
    return vim.iter(vim.lsp.get_clients({ bufnr = 0 })):any(function(client) return client.name == "pyright" end)
  end, 100)
  contexts.python = vim.api.nvim_get_current_buf()

  local help = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_set_current_buf(help)
  vim.bo[help].filetype = "help"
  vim.cmd("doautocmd FileType help")
  vim.wait(100)
  contexts.help = help

  return contexts, temp_root, original_watchfunc
end

local function cleanup_contexts(contexts, temp_root, original_watchfunc)
  for _, client in ipairs(vim.lsp.get_clients({ bufnr = contexts.python })) do
    pcall(client.stop, client, true)
  end
  for _, buffer in pairs(contexts) do
    if vim.api.nvim_buf_is_valid(buffer) then pcall(vim.api.nvim_buf_delete, buffer, { force = true }) end
  end
  vim.lsp._watchfiles._watchfunc = original_watchfunc
  vim.fn.delete(temp_root, "rf")
end

local function run_bindings(contexts)
  local results = {}
  for _, item in ipairs(all_entries()) do
    for index, binding in ipairs(item.bindings) do
      local ok, detail
      if binding.kind == "map" then
        ok, detail = map_result(binding, contexts)
      elseif binding.kind == "command" then
        ok, detail = command_result(binding, contexts)
      else
        ok, detail = capability_result(binding)
      end
      results[#results + 1] = {
        id = item.id,
        display = table.concat(item.display, " / "),
        action = item.text,
        binding = index,
        kind = binding.kind,
        context = binding.context,
        lhs = binding.lhs or binding.command or binding.capability,
        mode = binding.mode,
        ok = ok,
        detail = detail,
      }
    end
  end
  return results
end

local function escape_html(text)
  return tostring(text):gsub("&", "&amp;"):gsub("<", "&lt;"):gsub(">", "&gt;"):gsub('"', "&quot;")
end

local function render_keys(keys)
  local out = {}
  for _, key in ipairs(keys) do out[#out + 1] = "<kbd>" .. escape_html(key) .. "</kbd>" end
  return table.concat(out, " ")
end

local function render_card(card)
  local rows = {}
  for _, item in ipairs(card.rows) do
    rows[#rows + 1] = ('<div class="row"><div class="key">%s</div><div class="desc">%s</div></div>'):format(
      render_keys(item.display), escape_html(item.text)
    )
  end
  return ('<section class="card%s"><h2><span class="badge %s">%s</span>%s</h2><div class="rows">%s</div></section>'):format(
    card.grow and " grow" or "", card.color, escape_html(card.icon), escape_html(card.title), table.concat(rows, "\n")
  )
end

local function render_column(column)
  local parts = {}
  for _, card in ipairs(column.cards) do parts[#parts + 1] = render_card(card) end
  parts[#parts + 1] = '<div class="note">' .. column.note .. "</div>"
  return '<div class="column">' .. table.concat(parts, "\n") .. "</div>"
end

local function render_quickbar()
  local parts = {}
  for _, quick in ipairs(M.quickbar) do
    local item = assert(entry_by_id(quick.id), "missing quickbar entry: " .. quick.id)
    parts[#parts + 1] = ('<div class="quick">%s<br>%s</div>'):format(escape_html(quick.label), render_keys(item.display))
  end
  return table.concat(parts, "\n")
end

local function result_counts(results)
  local passed = 0
  for _, result in ipairs(results) do if result.ok then passed = passed + 1 end end
  return passed, #results
end

local function generate_html(results)
  local template = assert(read_text(config_dir .. "/templates/cheatsheet-ipad.html"), "missing HTML template")
  local passed, total = result_counts(results)
  template = template:gsub("{{QUICKBAR}}", render_quickbar())
  for index, column in ipairs(M.columns) do
    template = template:gsub("{{COLUMN_" .. index .. "}}", render_column(column))
  end
  template = template:gsub("{{AUDIT_STATUS}}", ("自动审计 %d/%d 通过"):format(passed, total))
  template = template:gsub("{{DATE}}", os.date("%Y-%m-%d"))
  write_text(html_path, template)
end

local function generate_markdown(results)
  local passed, total = result_counts(results)
  local lines = {
    "# LazyVim 中文小抄",
    "",
    ("> 此文件与 iPad 图片由同一键位清单生成。最近一次确定性审计：**%d/%d 通过**。"):format(passed, total),
    "",
    "`Space` = Leader，`\\` = LocalLeader。",
    "",
  }
  for _, column in ipairs(M.columns) do
    for _, card in ipairs(column.cards) do
      lines[#lines + 1] = "## " .. card.title
      lines[#lines + 1] = ""
      lines[#lines + 1] = "| 按键 | 作用 |"
      lines[#lines + 1] = "|---|---|"
      for _, item in ipairs(card.rows) do
        local keys = {}
        for _, key in ipairs(item.display) do keys[#keys + 1] = "`" .. key .. "`" end
        lines[#lines + 1] = ("| %s | %s |"):format(table.concat(keys, " / "), item.text)
      end
      lines[#lines + 1] = ""
    end
    lines[#lines + 1] = column.note:gsub("<strong>", "**"):gsub("</strong>", "**"):gsub("<code>", "`"):gsub("</code>", "`")
    lines[#lines + 1] = ""
  end
  lines[#lines + 1] = "完整逐项审计结果见 `CHEATSHEET-AUDIT.md`。"
  lines[#lines + 1] = ""
  write_text(markdown_path, table.concat(lines, "\n"))
end

local function generate_report(results, fingerprint)
  local passed, total = result_counts(results)
  local lines = {
    "# LazyVim 小抄确定性审计",
    "",
    ("- 结果：**%d/%d 通过**"):format(passed, total),
    "- 时间：" .. os.date("%Y-%m-%d %H:%M:%S %z"),
    "- 配置指纹：`" .. fingerprint .. "`",
    "- 原则：每一个显示键位都来自同一份清单；映射检查实际 `lhs`、mode、上下文、description，并在可稳定比较时检查 RHS。",
    "",
    "| 状态 | 显示键位 | 上下文 | 被检查对象 | 预期结果 | 实际结果 |",
    "|---|---|---|---|---|---|",
  }
  for _, result in ipairs(results) do
    local status = result.ok and "PASS" or "FAIL"
    local function cell(value) return tostring(value or ""):gsub("|", "\\|"):gsub("\n", " ") end
    lines[#lines + 1] = ("| %s | `%s` | %s | `%s` | %s | %s |"):format(
      status, cell(result.display), cell(result.context), cell(result.lhs), cell(result.action), cell(result.detail)
    )
  end
  lines[#lines + 1] = ""
  write_text(report_path, table.concat(lines, "\n"))
end

function M.fingerprint()
  local paths = {
    config_dir .. "/init.lua",
    config_dir .. "/lazy-lock.json",
    config_dir .. "/lazyvim.json",
    config_dir .. "/templates/cheatsheet-ipad.html",
    config_dir .. "/scripts/cheatsheet-audit.lua",
    config_dir .. "/scripts/build-cheatsheet.sh",
  }
  for _, pattern in ipairs({
    "lua/**/*.lua",
    "after/**/*.lua", "after/**/*.vim",
    "plugin/**/*.lua", "plugin/**/*.vim",
    "ftplugin/**/*.lua", "ftplugin/**/*.vim",
  }) do
    vim.list_extend(paths, vim.fn.globpath(config_dir, pattern, false, true))
  end
  table.sort(paths)
  local parts = { vim.version().major .. "." .. vim.version().minor .. "." .. vim.version().patch }
  for _, path in ipairs(paths) do
    parts[#parts + 1] = path
    parts[#parts + 1] = read_text(path) or "<missing>"
  end
  return vim.fn.sha256(table.concat(parts, "\0"))
end

function M.run_full(opts)
  opts = opts or {}
  local contexts, temp_root, original_watchfunc = prepare_contexts()
  local results = run_bindings(contexts)
  cleanup_contexts(contexts, temp_root, original_watchfunc)
  local fingerprint = M.fingerprint()
  local passed, total = result_counts(results)
  generate_report(results, fingerprint)
  if passed == total and opts.generate then
    generate_markdown(results)
    generate_html(results)
  end
  if passed == total and opts.seal then
    write_text(manifest_path, vim.json.encode({
      schema = 1,
      fingerprint = fingerprint,
      audited_at = os.date("!%Y-%m-%dT%H:%M:%SZ"),
      passed = passed,
      total = total,
      nvim = tostring(vim.version()),
    }))
  end
  return passed == total, { passed = passed, total = total, report = report_path }
end

local function global_runtime_failures()
  local failures = {}
  local maps_by_mode = {}
  local function global_map(lhs, mode)
    mode = mode or "n"
    maps_by_mode[mode] = maps_by_mode[mode] or vim.api.nvim_get_keymap(mode)
    local expanded_text = expand(lhs)
    local expanded_raw = vim.api.nvim_replace_termcodes(expanded_text, true, true, true)
    for _, actual in ipairs(maps_by_mode[mode]) do
      local lhs_text = actual.lhs or ""
      local lhs_trans = vim.fn.keytrans(actual.lhsraw or "")
      local ctrl_alias = expanded_text:find("<C-", 1, true)
        and lhs_text:lower() == expanded_text:lower()
      if lhs_text == expanded_text or lhs_trans == vim.fn.keytrans(expanded_raw) or ctrl_alias then return actual end
    end
  end
  for _, item in ipairs(all_entries()) do
    for _, binding in ipairs(item.bindings) do
      if binding.kind == "map" and binding.context == "global" then
        local actual = global_map(binding.lhs, binding.mode)
        if not actual
          or (binding.desc and actual.desc ~= binding.desc)
        then
          failures[#failures + 1] = item.display[1]
        end
      end
    end
  end
  return failures
end

function M.startup_check()
  if vim.g.cheatsheet_audit_process then return end
  local reasons = {}
  local manifest_text = read_text(manifest_path)
  local ok, manifest = pcall(vim.json.decode, manifest_text or "")
  if not ok or type(manifest) ~= "table" then
    reasons[#reasons + 1] = "没有有效的审计记录"
  elseif manifest.fingerprint ~= M.fingerprint() then
    reasons[#reasons + 1] = "配置、插件锁文件或生成器已变化"
  end
  local failures = global_runtime_failures()
  if #failures > 0 then reasons[#reasons + 1] = "当前全局映射不匹配：" .. table.concat(failures, "、") end
  if #reasons > 0 then
    vim.notify(
      "LazyVim 小抄可能已经过期：" .. table.concat(reasons, "；") .. "。\n运行 :NvimCheatsheetAudit 查看逐项结果。",
      vim.log.levels.WARN,
      { title = "小抄键位漂移检测" }
    )
  end
end

local function run_external(command_line, title)
  vim.notify(title .. "已启动；完成后会通知。", vim.log.levels.INFO, { title = "LazyVim 小抄" })
  vim.system(command_line, { text = true }, function(result)
    vim.schedule(function()
      if result.code == 0 then
        vim.notify(title .. "通过。", vim.log.levels.INFO, { title = "LazyVim 小抄" })
      else
        vim.notify(title .. "失败；请查看 " .. report_path .. "\n" .. trim(result.stderr), vim.log.levels.ERROR, { title = "LazyVim 小抄" })
      end
    end)
  end)
end

local function run_child(path, title)
  run_external({
    vim.v.progpath,
    "--headless",
    "-i", "NONE",
    "--cmd", "let g:cheatsheet_audit_process=1",
    "-c", "luafile " .. vim.fn.fnameescape(path),
  }, title)
end

function M.setup()
  vim.api.nvim_create_user_command("NvimCheatsheet", function()
    vim.cmd("tabnew " .. vim.fn.fnameescape(markdown_path))
  end, { desc = "Open the generated Chinese LazyVim cheat sheet", force = true })

  vim.api.nvim_create_user_command("NvimCheatsheetImage", function()
    vim.cmd("tabnew " .. vim.fn.fnameescape(image_path))
  end, { desc = "Open the audited iPad Pro LazyVim cheat-sheet image", force = true })

  vim.api.nvim_create_user_command("NvimCheatsheetAudit", function()
    run_child(config_dir .. "/scripts/cheatsheet-audit.lua", "全部键位审计")
  end, { desc = "Audit every shortcut shown on the LazyVim cheat sheet", force = true })

  vim.api.nvim_create_user_command("NvimCheatsheetBuild", function()
    run_external({ config_dir .. "/scripts/build-cheatsheet.sh" }, "小抄审计与重建")
  end, { desc = "Audit and rebuild all LazyVim cheat-sheet artifacts", force = true })

  vim.defer_fn(function() M.startup_check() end, 800)
end

return M
