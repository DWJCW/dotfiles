local platform = require("config.platform")

local function configure_vimtex_viewer()
  local viewer = platform.pdf_viewer()

  -- VimTeX supports a dedicated Zathura and Skim backend. Okular and the
  -- desktop fallback use VimTeX's generic viewer backend.
  vim.g.vimtex_view_method = viewer.method
  vim.g.vimtex_view_skim_sync = 0
  vim.g.vimtex_view_skim_activate = 0

  if viewer.method == "skim" then
    vim.g.vimtex_view_skim_sync = 1
    vim.g.vimtex_view_skim_activate = 1
  else
    -- Keep the generic backend deterministic even when the selected viewer
    -- is not currently installed. VimTeX will report a view-time warning;
    -- its startup remains usable.
    vim.g.vimtex_view_general_viewer = viewer.command or viewer.fallback_command
    vim.g.vimtex_view_general_options = "@pdf"
  end

  if viewer.warning then
    vim.schedule(function()
      vim.notify(viewer.warning, vim.log.levels.WARN, { title = "Dotfiles PDF 能力" })
    end)
  end
end

return {
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "tokyonight",
    },
  },

  -- Show the open-buffer bar even when only one buffer is listed.
  {
    "akinsho/bufferline.nvim",
    opts = {
      options = {
        always_show_bufferline = true,
      },
    },
  },

  -- Open standalone images and PDFs in Neovim. Source documents are kept as
  -- plain editable text: no inline image or formula rendering in TeX/Markdown.
  {
    "folke/snacks.nvim",
    opts = {
      image = {
        enabled = true,
        doc = {
          enabled = false,
        },
      },
    },
  },

  -- Install the complete selected language toolchain even during headless
  -- bootstrap. Mason's LSP auto-installer intentionally skips headless runs.
  {
    "mason-org/mason.nvim",
    opts = {
      ensure_installed = {
        "bash-language-server",
        "clangd",
        "json-lsp",
        "lua-language-server",
        "marksman",
        "neocmakelsp",
        "pyright",
        "ruff",
        "shellcheck",
        "taplo",
        "texlab",
        "yaml-language-server",
      },
    },
  },

  -- Bash has no dedicated LazyVim language extra; add its standard LSP to the
  -- same LazyVim/Mason server table used by all other selected languages.
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        bashls = {},
      },
    },
  },

  -- Keep Markdown diagnostics quiet by default. The Markdown extra still
  -- provides Marksman, preview, and formatting support.
  {
    "mfussenegger/nvim-lint",
    optional = true,
    opts = function(_, opts)
      opts.linters_by_ft = opts.linters_by_ft or {}
      opts.linters_by_ft.markdown = {}
    end,
  },

  -- Match the thesis repository: XeLaTeX, latexmk, build/, and the selected
  -- platform PDF viewer. Platform detection stays in config.platform.
  {
    "lervag/vimtex",
    init = function()
      configure_vimtex_viewer()
      vim.g.vimtex_compiler_method = "latexmk"
      vim.g.vimtex_quickfix_mode = 2
      vim.g.vimtex_quickfix_open_on_warning = 0
      vim.g.vimtex_compiler_latexmk_engines = {
        ["_"] = "-xelatex",
        xelatex = "-xelatex",
      }
      vim.g.vimtex_compiler_latexmk = {
        out_dir = "build",
        options = {
          "-verbose",
          "-file-line-error",
          "-synctex=1",
          "-interaction=nonstopmode",
          "-halt-on-error",
        },
      }
    end,
  },
}
