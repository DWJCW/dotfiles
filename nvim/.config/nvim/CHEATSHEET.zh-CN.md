# LazyVim 中文小抄

> 此文件与 iPad 图片由同一键位清单生成。最近一次确定性审计：**69/69 通过**。

`Space` = Leader，`\` = LocalLeader。

## 文件、搜索与文件树

| 按键 | 作用 |
|---|---|
| `Space e` | 项目文件树 |
| `Space Space` | 查找项目文件 |
| `Space f f` | 同上：查找文件 |
| `Space /` | 全文搜索 |
| `Space s w` | 搜索当前词/选区 |
| `Space f r` | 最近文件 |
| `Space s k` | 搜索所有快捷键 |

## Buffer、编辑分屏与 Tab

| 按键 | 作用 |
|---|---|
| `Shift h / l` | 前/后一个 buffer |
| `[ b` / `] b` | 前/后一个 buffer |
| `Space ,` | 列出并选择 buffer |
| `Space b d` | 关闭当前 buffer |
| `Space b o` | 关闭其他 buffer |
| `Ctrl h/j/k/l` | 移动到相邻编辑分屏 |
| `Space |` / `Space -` | 左右/上下打开编辑分屏 |
| `q` | 关闭文件树/选择器/帮助窗 |
| `Space w d` | 关闭当前编辑分屏 |
| `Space Tab Tab` | 新建 tabpage |
| `Space Tab [` / `Space Tab ]` | 前/后一个 tabpage |

**窗口要分清：**`Space | / Space -` 打开编辑分屏，`Space w d` 关闭编辑分屏；`q` 关闭文件树、选择器、help 等工具窗口；`Space b d` 关闭文件 buffer。

## LaTeX / VimTeX

| 按键 | 作用 |
|---|---|
| `\ l l` | 启动/停止持续编译 |
| `\ l v` | Skim 正向跳转 |
| `\ l e` | 查看编译错误 |
| `\ l o` | 完整编译输出 |
| `\ l i` | VimTeX 项目信息 |
| `\ l t` | LaTeX 目录 |
| `\ l k` | 停止编译器 |
| `\ l c` | 清理普通编译产物 |
| `⇧⌘ + 点击 PDF` | Skim 反向跳回源码 |

## 编辑、诊断与 LSP

| 按键 | 作用 |
|---|---|
| `Ctrl s` | 保存 |
| `Space c f` | 格式化文件/选区 |
| `g d` | 跳到定义 |
| `g r` | 查找引用 |
| `K` | 光标处文档说明 |
| `Space c r` | 重命名符号 |
| `Space c a` | Code Action |
| `[ d` / `] d` | 前/后一个诊断 |
| `Space x x` | 项目诊断列表 |
| `Space c v` | Python 选择虚拟环境 |

**当前工具链：**Pyright + Ruff · Texlab + VimTeX · Marksman · JSON/YAML/TOML/Bash LSP。AI、DAP 和测试框架未启用。

## Markdown 与图片

| 按键 | 作用 |
|---|---|
| `Space c p` | 浏览器 Markdown 预览 |
| `Space u m` | Nvim 内 Markdown 美化 |
| `:edit 图.png` | Nvim 内预览图片 |
| `:edit 文档.pdf` | Nvim 内快速看 PDF |
| `g x` | 用系统应用打开目标 |

## Git 与终端

| 按键 | 作用 |
|---|---|
| `Space g g` | 项目根目录 Lazygit |
| `Space g s` | Git 状态 |
| `[ h` / `] h` | 前/后一个修改块 |
| `Space g h p` | 预览当前修改块 |
| `Space f t` | 项目根目录终端 |
| `Ctrl /` | 显示/隐藏浮动终端 |

## 帮助与维护

| 按键 | 作用 |
|---|---|
| `Space（稍等）` | which-key 提示 |
| `Space ?` | 当前 buffer 快捷键 |
| `:NvimCheatsheetImage` | 打开本图片 |
| `:NvimCheatsheetAudit` | 审计全部小抄键位 |
| `:Lazy` | 插件管理 |
| `:Mason` | 语言工具管理 |
| `:checkhealth` | 健康检查 |
| `:VimtexInfo` | LaTeX 故障排查 |

**防漂移：**配置或插件锁文件变化后，启动 Nvim 会提醒。运行 `:NvimCheatsheetAudit` 可逐项复核；有失败时不会覆盖小抄。

完整逐项审计结果见 `CHEATSHEET-AUDIT.md`。
