-- ~/.config/nvim/lua/config/keymaps.lua
local map = vim.keymap.set
local opts = { noremap = true, silent = true }

local function close_current_buffer()
  local current = vim.api.nvim_get_current_buf()
  local listed = vim.tbl_filter(function(buf)
    return vim.api.nvim_buf_is_valid(buf) and vim.bo[buf].buflisted
  end, vim.api.nvim_list_bufs())

  if #listed <= 1 then
    vim.cmd("enew")
    vim.cmd("bdelete " .. current)
    return
  end

  vim.cmd("bprevious")
  vim.cmd("bdelete " .. current)
end

-- Leader
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

-- Neo-tree toggle
map("n", "<leader>e", "<cmd>Neotree toggle<CR>", { desc = "Toggle Neo-tree" })
map("n", "<C-n>", "<cmd>Neotree toggle<CR>", { desc = "Toggle Neo-tree" })

-- Buffer navigation
map("n", "[b", "<cmd>BufferLineCyclePrev<CR>", { desc = "Previous buffer" })
map("n", "]b", "<cmd>BufferLineCycleNext<CR>", { desc = "Next buffer" })
map("n", "<leader>bn", "<cmd>enew<CR>", { desc = "New buffer" })
map("n", "<leader>bp", "<cmd>BufferLinePick<CR>", { desc = "Pick buffer" })
map("n", "<leader>bd", close_current_buffer, { desc = "Delete buffer" })
map("n", "<leader>bo", "<cmd>%bd|e#|bd#<CR>", { desc = "Delete other buffers" })

-- Navigation between splits
map("n", "<C-h>", "<C-w>h", opts)
map("n", "<C-j>", "<C-w>j", opts)
map("n", "<C-k>", "<C-w>k", opts)
map("n", "<C-l>", "<C-w>l", opts)

-- Resize splits
map("n", "<A-h>", "<C-w><", opts)
map("n", "<A-l>", "<C-w>>", opts)
map("n", "<A-j>", "<C-w>-", opts)
map("n", "<A-k>", "<C-w>+", opts)

-- Clear search highlight
map("n", "<Esc>", "<cmd>noh<CR>", opts)

-- Stay in visual mode when indenting
map("v", "<", "<gv", opts)
map("v", ">", ">gv", opts)

-- Move lines
map("v", "J", ":m '>+1<CR>gv=gv", opts)
map("v", "K", ":m '<-2<CR>gv=gv", opts)
