-- ~/.config/nvim/lua/plugins/neo-tree.lua
return {
  {
    "nvim-neo-tree/neo-tree.nvim",
    branch = "v3.x",
    cmd = "Neotree",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-tree/nvim-web-devicons",
      "MunifTanjim/nui.nvim",
    },
    keys = {
      { "<leader>e", "<cmd>Neotree toggle<CR>", desc = "Toggle Neo-tree" },
      { "<C-n>", "<cmd>Neotree toggle<CR>", desc = "Toggle Neo-tree" },
    },
    opts = {
      close_if_last_window = true,
      popup_border_style = "rounded",
      enable_git_status = true,
      enable_diagnostics = true,
      default_component_configs = {
        indent = { with_expanders = true, expander_collapsed = "", expander_expanded = "" },
        icon = { folder_closed = "", folder_open = "", folder_empty = "", folder_empty_open = "" },
        git_status = {
          symbols = { added = "", deleted = "", modified = "", renamed = "", untracked = "", ignored = "", unstaged = "", staged = "", conflict = "" },
        },
      },
      window = { position = "left", width = 35, mappings = { ["o"] = "open", ["<CR>"] = "open" } },
      filesystem = {
        filtered_items = { visible = false, hide_dotfiles = false, hide_gitignored = false },
        follow_current_file = { enabled = true },
      },
    },
  },
}
