return {
  "lervag/vimtex",
  lazy = false,
  init = function()
    -- vimtex settings
    vim.g.vimtex_view_method = "skim"
    vim.g.vimtex_compiler_method = "latexmk"
    vim.g.tex_flavor = "latex"
  end,
}
