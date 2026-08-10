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
        "json-lsp",
        "lua-language-server",
        "marksman",
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

  -- Match the thesis repository: XeLaTeX, latexmk, build/, and Skim SyncTeX.
  {
    "lervag/vimtex",
    init = function()
      vim.g.vimtex_view_method = "skim"
      vim.g.vimtex_view_skim_sync = 1
      vim.g.vimtex_view_skim_activate = 1
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
