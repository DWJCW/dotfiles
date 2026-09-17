return {
  {
    "folke/snacks.nvim",
    opts = {
      picker = {
        actions = {
          explorer_yank = function(picker)
            require("snacks.explorer.actions").actions.explorer_yank(picker)
            -- LazyVim leaves 'clipboard' empty over SSH. The default explorer
            -- yank therefore stays in the unnamed register; send the same paths
            -- to the client terminal without changing normal editing/paste.
            if vim.env.SSH_CONNECTION and vim.v.register == '"' then
              require("vim.ui.clipboard.osc52").copy("+")(vim.fn.getreg('"', 1, true))
            end
          end,
        },
      },
    },
  },
}
