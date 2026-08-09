-- ~/.config/nvim/lua/plugins/markdown.lua
return {
  -- Rich markdown rendering
  {
    "MeanderingProgrammer/render-markdown.nvim",
    ft = { "markdown", "norg", "rmd", "org" },
    dependencies = { "nvim-treesitter/nvim-treesitter", "nvim-tree/nvim-web-devicons" },
    opts = {
      heading = {
        enabled = true,
        sign = true,
        icons = { "󰉫 ", "󰉬 ", "󰉭 ", "󰉮 ", "󰉯 ", "󰉰 " },
      },
      code = { enabled = true, sign = false, style = "language" },
      dash = { enabled = true },
      bullet = { enabled = true },
      quote = { enabled = true },
      pipe_table = { enabled = true },
      sign = { enabled = false },
    },
  },

  -- Markdown preview in browser (fallback when terminal image rendering doesn't work)
  {
    "iamcco/markdown-preview.nvim",
    cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
    ft = { "markdown" },
    build = "cd app && npm install",
  },
}
