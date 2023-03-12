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
