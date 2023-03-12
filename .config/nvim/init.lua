vim.g.mapleader = " "
vim.o.tabstop = 2
vim.o.shiftwidth = 2
vim.o.softtabstop = 2
vim.o.expandtab = true
vim.o.signcolumn = "number"
vim.o.number = true
vim.o.mouse = nil
vim.opt.termguicolors = true

vim.keymap.set("n", "<Leader>h", "<cmd>noh<cr>")
vim.keymap.set("n", "<leader>y", '"+y<cr>')
vim.keymap.set("n", "<leader>p", '"+p<cr>')

require "plugins" 

require("one_monokai").setup({ transparent = true })

local telescope = require("telescope.builtin")
vim.keymap.set("n", "<leader>ff", telescope.find_files, {})
vim.keymap.set("n", "<leader>fg", telescope.live_grep, {})
vim.keymap.set("n", "<leader>fb", telescope.buffers, {})
vim.keymap.set("n", "<leader>fh", telescope.help_tags, {})
-- https://github.com/neovim/nvim-lspconfig/issues/1046#issuecomment-1396124472
vim.keymap.set("n", "<leader>le", vim.diagnostic.open_float, {})

