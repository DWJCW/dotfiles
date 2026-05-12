-- ~/.config/nvim/lua/plugins/treesitter.lua
return {
  {
    "nvim-treesitter/nvim-treesitter",
    lazy = false,
    build = ":TSUpdate",
    config = function()
      require("nvim-treesitter").setup({})

      -- Bootstrap parsers synchronously (block until done, max 2 min)
      require("nvim-treesitter").install({
        "lua",
        "vim",
        "vimdoc",
        "python",
        "markdown",
        "markdown_inline",
        "latex",
        "bash",
        "json",
        "yaml",
        "toml",
      }):wait(120000)

      -- Enable treesitter highlighting for common filetypes
      -- Leave TeX and LaTeX highlighting to vimtex.
      local enable_ts = function(args)
        pcall(vim.treesitter.start, args.buf, nil)
      end
      vim.api.nvim_create_autocmd("FileType", {
        pattern = { "lua", "vim", "python", "markdown", "bash", "sh", "json", "yaml", "toml" },
        callback = enable_ts,
      })
    end,
  },
}
