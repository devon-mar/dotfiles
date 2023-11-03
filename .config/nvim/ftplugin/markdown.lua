-- vim.keymap.set("n", "<leader>bp", ":!pandoc % -o " .. vim.fn.expand("%:r") .. ".pdf<CR>", { noremap = true })
local augroup = vim.api.nvim_create_augroup("PandocPDF", { clear = false })

vim.api.nvim_buf_create_user_command(0, "PandocEnable", function()
  vim.api.nvim_clear_autocmds({ group = augroup, buffer = 0 })
  vim.api.nvim_create_autocmd("BufWritePost", {
    group = augroup,
    buffer = 0,
    callback = function()
      local output = vim.fn.system({ "pandoc", vim.fn.expand("%:p"), "-o", vim.fn.expand("%:p:r") .. ".pdf" })
      vim.notify("pandoc exited with code " .. vim.v.shell_error .. ": " .. output)
    end,
  })
end, { nargs = 0 })

vim.wo.wrap = true
vim.o.textwidth = 100
vim.opt_local.spell = true
