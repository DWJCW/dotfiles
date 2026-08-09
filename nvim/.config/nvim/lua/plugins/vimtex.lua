return {
  "lervag/vimtex",
  lazy = false,
  init = function()
    -- vimtex settings
    vim.g.vimtex_view_method = "skim"
    vim.g.vimtex_compiler_method = "latexmk"
    -- Do not open quickfix for warnings after a successful compilation, while
    -- preserving automatic quickfix display for genuine compilation errors.
    vim.g.vimtex_quickfix_mode = 2
    vim.g.vimtex_quickfix_open_on_warning = 0
    -- This thesis loads fontspec, so pdflatex cannot compile it.  Make
    -- XeLaTeX the fallback engine for every VimTeX latexmk project.
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
    vim.g.tex_flavor = "latex"
  end,
}
