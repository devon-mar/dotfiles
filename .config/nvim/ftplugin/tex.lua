local augroup = vim.api.nvim_create_augroup("PdfLatex", { clear = false })

vim.api.nvim_buf_create_user_command(0, "Pdflatex", function()
  vim.api.nvim_clear_autocmds({ group = augroup, buffer = 0 })
  vim.api.nvim_create_autocmd("BufWritePost", {
    group = augroup,
    buffer = 0,
    callback = function()
      local output = vim.fn.system({
        "pdflatex",
        "-interaction=nonstopmode",
        "-output-directory",
        vim.fn.expand("%:p:h"),
        vim.fn.expand("%:p"),
      })
      if vim.v.shell_error == 0 then
        vim.notify("compiled successfully")
      else
        vim.notify("pdflatex exited with code " .. vim.v.shell_error .. ": " .. output)
      end
    end,
  })
end, { nargs = 0 })

vim.wo.wrap = true
vim.o.textwidth = 100
vim.opt_local.spell = true
