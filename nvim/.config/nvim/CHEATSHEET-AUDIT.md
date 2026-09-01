# LazyVim 小抄确定性审计

- 结果：**68/69 通过**
- 时间：2026-08-27 18:51:44 +0800
- 配置指纹：`34732c0097bd38501eb68ff2f95faf94f3180d90308097c0c73e0057c273e8d1`
- 原则：每一个显示键位都来自同一份清单；映射检查实际 `lhs`、mode、上下文、description，并在可稳定比较时检查 RHS。

| 状态 | 显示键位 | 上下文 | 被检查对象 | 预期结果 | 实际结果 |
|---|---|---|---|---|---|
| PASS | `Space e` | global | `<leader>e` | 项目文件树 | Explorer Snacks (root dir) → <leader>fe |
| PASS | `Space Space` | global | `<leader><space>` | 查找项目文件 | Find Files (Root Dir) → <Lua callback> @ ....local/share/nvim/lazy/LazyVim/lua/lazyvim/util/pick.lua:70 |
| PASS | `Space f f` | global | `<leader>ff` | 同上：查找文件 | Find Files (Root Dir) → <Lua callback> @ ....local/share/nvim/lazy/LazyVim/lua/lazyvim/util/pick.lua:70 |
| PASS | `Space /` | global | `<leader>/` | 全文搜索 | Grep (Root Dir) → <Lua callback> @ ....local/share/nvim/lazy/LazyVim/lua/lazyvim/util/pick.lua:70 |
| PASS | `Space s w` | global | `<leader>sw` | 搜索当前词/选区 | Visual selection or word (Root Dir) → <Lua callback> @ ....local/share/nvim/lazy/LazyVim/lua/lazyvim/util/pick.lua:70 |
| PASS | `Space s w` | global | `<leader>sw` | 搜索当前词/选区 | Visual selection or word (Root Dir) → <Lua callback> @ ....local/share/nvim/lazy/LazyVim/lua/lazyvim/util/pick.lua:70 |
| PASS | `Space f r` | global | `<leader>fr` | 最近文件 | Recent → <Lua callback> @ ....local/share/nvim/lazy/LazyVim/lua/lazyvim/util/pick.lua:70 |
| PASS | `Space s k` | global | `<leader>sk` | 搜索所有快捷键 | Keymaps → <Lua callback> @ ...yVim/lua/lazyvim/plugins/extras/editor/snacks_picker.lua:103 |
| PASS | `Shift h / l` | global | `<S-h>` | 前/后一个 buffer | Prev Buffer → <cmd>BufferLineCyclePrev<cr> |
| PASS | `Shift h / l` | global | `<S-l>` | 前/后一个 buffer | Next Buffer → <cmd>BufferLineCycleNext<cr> |
| PASS | `[ b / ] b` | global | `[b` | 前/后一个 buffer | Prev Buffer → <cmd>BufferLineCyclePrev<cr> |
| PASS | `[ b / ] b` | global | `]b` | 前/后一个 buffer | Next Buffer → <cmd>BufferLineCycleNext<cr> |
| PASS | `Space ,` | global | `<leader>,` | 列出并选择 buffer | Buffers → <Lua callback> @ ...yVim/lua/lazyvim/plugins/extras/editor/snacks_picker.lua:59 |
| PASS | `Space b d` | global | `<leader>bd` | 关闭当前 buffer | Delete Buffer → <Lua callback> @ ...l/share/nvim/lazy/LazyVim/lua/lazyvim/config/keymaps.lua:40 |
| PASS | `Space b o` | global | `<leader>bo` | 关闭其他 buffer | Delete Other Buffers → <Lua callback> @ ...l/share/nvim/lazy/LazyVim/lua/lazyvim/config/keymaps.lua:43 |
| PASS | `Ctrl h/j/k/l` | global | `<C-h>` | 移动到相邻编辑分屏 | Go to Left Window → <C-w>h |
| PASS | `Ctrl h/j/k/l` | global | `<C-j>` | 移动到相邻编辑分屏 | Go to Lower Window → <C-w>j |
| PASS | `Ctrl h/j/k/l` | global | `<C-k>` | 移动到相邻编辑分屏 | Go to Upper Window → <C-w>k |
| PASS | `Ctrl h/j/k/l` | global | `<C-l>` | 移动到相邻编辑分屏 | Go to Right Window → <C-w>l |
| PASS | `Space \| / Space -` | global | `<leader>\|` | 左右/上下打开编辑分屏 | Split Window Right → <C-W>v |
| PASS | `Space \| / Space -` | global | `<leader>-` | 左右/上下打开编辑分屏 | Split Window Below → <C-W>s |
| PASS | `q` | help | `q` | 关闭文件树/选择器/帮助窗 | Quit buffer → <Lua callback> @ .../share/nvim/lazy/LazyVim/lua/lazyvim/config/autocmds.lua:81 |
| PASS | `q` | global | `snacks_picker_q` | 关闭文件树/选择器/帮助窗 | Snacks q：input=cancel, list=cancel, preview=cancel |
| PASS | `Space w d` | global | `<leader>wd` | 关闭当前编辑分屏 | Delete Window → <C-W>c |
| PASS | `Space Tab Tab` | global | `<leader><tab><tab>` | 新建 tabpage | New Tab → <cmd>tabnew<cr> |
| PASS | `Space Tab [ / Space Tab ]` | global | `<leader><tab>[` | 前/后一个 tabpage | Previous Tab → <cmd>tabprevious<cr> |
| PASS | `Space Tab [ / Space Tab ]` | global | `<leader><tab>]` | 前/后一个 tabpage | Next Tab → <cmd>tabnext<cr> |
| PASS | `\ l l` | tex | `<localleader>ll` | 启动/停止持续编译 | <plug>(vimtex-compile) |
| PASS | `\ l v` | tex | `<localleader>lv` | Skim 正向跳转 | <plug>(vimtex-view) |
| PASS | `\ l e` | tex | `<localleader>le` | 查看编译错误 | <plug>(vimtex-errors) |
| PASS | `\ l o` | tex | `<localleader>lo` | 完整编译输出 | <plug>(vimtex-compile-output) |
| PASS | `\ l i` | tex | `<localleader>li` | VimTeX 项目信息 | <plug>(vimtex-info) |
| PASS | `\ l t` | tex | `<localleader>lt` | LaTeX 目录 | <plug>(vimtex-toc-open) |
| PASS | `\ l k` | tex | `<localleader>lk` | 停止编译器 | <plug>(vimtex-stop) |
| PASS | `\ l c` | tex | `<localleader>lc` | 清理普通编译产物 | <plug>(vimtex-clean) |
| FAIL | `⇧⌘ + 点击 PDF` | tex | `skim_inverse` | Skim 反向跳回源码 | Skim preset=, editor=, inverse=false |
| PASS | `Ctrl s` | global | `<C-s>` | 保存 | Save File → <cmd>w<cr><esc> |
| PASS | `Space c f` | global | `<leader>cf` | 格式化文件/选区 | Format → <Lua callback> @ ...l/share/nvim/lazy/LazyVim/lua/lazyvim/config/keymaps.lua:120 |
| PASS | `Space c f` | global | `<leader>cf` | 格式化文件/选区 | Format → <Lua callback> @ ...l/share/nvim/lazy/LazyVim/lua/lazyvim/config/keymaps.lua:120 |
| PASS | `g d` | python | `gd` | 跳到定义 | Goto Definition → <Lua callback> @ ...yVim/lua/lazyvim/plugins/extras/editor/snacks_picker.lua:147 |
| PASS | `g r` | python | `gr` | 查找引用 | References → <Lua callback> @ ...yVim/lua/lazyvim/plugins/extras/editor/snacks_picker.lua:148 |
| PASS | `K` | python | `K` | 光标处文档说明 | Hover → <Lua callback> @ ...share/nvim/lazy/LazyVim/lua/lazyvim/plugins/lsp/init.lua:85 |
| PASS | `Space c r` | python | `<leader>cr` | 重命名符号 | Rename → <Lua callback> @ ...lar/neovim/0.12.4/share/nvim/runtime/lua/vim/lsp/buf.lua:716 |
| PASS | `Space c a` | python | `<leader>ca` | Code Action | Code Action → <Lua callback> @ ...lar/neovim/0.12.4/share/nvim/runtime/lua/vim/lsp/buf.lua:1376 |
| PASS | `Space c a` | python | `<leader>ca` | Code Action | Code Action → <Lua callback> @ ...lar/neovim/0.12.4/share/nvim/runtime/lua/vim/lsp/buf.lua:1376 |
| PASS | `[ d / ] d` | global | `[d` | 前/后一个诊断 | Prev Diagnostic → <Lua callback> @ ...l/share/nvim/lazy/LazyVim/lua/lazyvim/config/keymaps.lua:126 |
| PASS | `[ d / ] d` | global | `]d` | 前/后一个诊断 | Next Diagnostic → <Lua callback> @ ...l/share/nvim/lazy/LazyVim/lua/lazyvim/config/keymaps.lua:126 |
| PASS | `Space x x` | global | `<leader>xx` | 项目诊断列表 | Diagnostics (Trouble) → <cmd>Trouble diagnostics toggle<cr> |
| PASS | `Space c v` | python | `<leader>cv` | Python 选择虚拟环境 | Select VirtualEnv → <cmd>:VenvSelect<cr> |
| PASS | `Space c p` | markdown | `<leader>cp` | 浏览器 Markdown 预览 | Markdown Preview → <cmd>MarkdownPreviewToggle<cr> |
| PASS | `Space u m` | markdown | `<leader>um` | Nvim 内 Markdown 美化 | Toggle Render Markdown → <Lua callback> @ ....local/share/nvim/lazy/snacks.nvim/lua/snacks/toggle.lua:120 |
| PASS | `:edit 图.png` | global | `snacks_image` | Nvim 内预览图片 | Snacks.image enabled=true, doc=false, format=true, tools=true |
| PASS | `:edit 文档.pdf` | global | `snacks_image` | Nvim 内快速看 PDF | Snacks.image enabled=true, doc=false, format=true, tools=true |
| PASS | `g x` | global | `gx` | 用系统应用打开目标 | Opens filepath or URI under cursor with the system handler (file explorer, web browser, …) → <Lua callback> @ vim/_core/defaults:157 |
| PASS | `Space g g` | global | `<leader>gg` | 项目根目录 Lazygit | Lazygit (Root Dir) → <Lua callback> @ ...l/share/nvim/lazy/LazyVim/lua/lazyvim/config/keymaps.lua:169 |
| PASS | `Space g s` | global | `<leader>gs` | Git 状态 | Git Status → <Lua callback> @ ...yVim/lua/lazyvim/plugins/extras/editor/snacks_picker.lua:77 |
| PASS | `[ h / ] h` | git | `[h` | 前/后一个修改块 | Prev Hunk → <Lua callback> @ ...l/share/nvim/lazy/LazyVim/lua/lazyvim/plugins/editor.lua:167 |
| PASS | `[ h / ] h` | git | `]h` | 前/后一个修改块 | Next Hunk → <Lua callback> @ ...l/share/nvim/lazy/LazyVim/lua/lazyvim/plugins/editor.lua:160 |
| PASS | `Space g h p` | git | `<leader>ghp` | 预览当前修改块 | Preview Hunk Inline → <Lua callback> @ ...l/share/nvim/lazy/gitsigns.nvim/lua/gitsigns/actions.lua:615 |
| PASS | `Space f t` | global | `<leader>ft` | 项目根目录终端 | Terminal (Root Dir) → <Lua callback> @ ...l/share/nvim/lazy/LazyVim/lua/lazyvim/config/keymaps.lua:194 |
| PASS | `Ctrl /` | global | `<C-/>` | 显示/隐藏浮动终端 | Terminal (Root Dir) → <Lua callback> @ ...l/share/nvim/lazy/LazyVim/lua/lazyvim/config/keymaps.lua:195 |
| PASS | `Space（稍等）` | global | `which_key` | which-key 提示 | which-key 已加载，Leader=Space |
| PASS | `Space ?` | global | `<leader>?` | 当前 buffer 快捷键 | Buffer Keymaps (which-key) → <Lua callback> @ ...l/share/nvim/lazy/LazyVim/lua/lazyvim/plugins/editor.lua:107 |
| PASS | `:NvimCheatsheetImage` | global | `NvimCheatsheetImage` | 打开本图片 | :NvimCheatsheetImage 已注册 |
| PASS | `:NvimCheatsheetAudit` | global | `NvimCheatsheetAudit` | 审计全部小抄键位 | :NvimCheatsheetAudit 已注册 |
| PASS | `:Lazy` | global | `Lazy` | 插件管理 | :Lazy 已注册 |
| PASS | `:Mason` | global | `Mason` | 语言工具管理 | :Mason 已注册 |
| PASS | `:checkhealth` | global | `checkhealth` | 健康检查 | :checkhealth 已注册 |
| PASS | `:VimtexInfo` | tex | `VimtexInfo` | LaTeX 故障排查 | :VimtexInfo 已注册 |
