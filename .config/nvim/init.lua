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
vim.keymap.set("n", "<leader>y", '"+y')
vim.keymap.set("v", "<leader>y", '"+y')
vim.keymap.set("n", "<leader>p", '"+p')
--- https://stackoverflow.com/questions/676600/vim-search-and-replace-selected-text
vim.keymap.set("v", "<C-r>", '"hy:%s/<C-r>h//g<left><left>')

vim.filetype.add({ pattern = { ["~/repos/workstation/.*.yml"] = "yaml.ansible" } })

--- Based on https://unix.stackexchange.com/questions/224771/what-is-the-format-of-the-default-statusline
vim.opt.statusline = [[%<%f %y%h%m%r%=%{get(b:,"gitsigns_status", "")} %-14.(%l,%c%V%) %P]]

--- https://github.com/neovim/nvim-lspconfig/wiki/UI-Customization#customizing-how-diagnostics-are-displayed
local signs = { Error = " ", Warn = " ", Hint = " ", Info = " " }
for type, icon in pairs(signs) do
  local hl = "DiagnosticSign" .. type
  vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = hl })
end

vim.diagnostic.config({
  virtual_text = {
    source = "if_many",
  },
  float = { source = "if_many" },
})

-- lazy bootstrap
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)
require("lazy").setup("plugins", {
  border = "rounded"
})
