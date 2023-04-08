-- https://github.com/akinsho/toggleterm.nvim/issues/214#issuecomment-1108868122
local extra = 'echo \"\\\\n\\\\033[0;33mPlease Press ENTER to continue \\\\033[0m\"; read; exit;'
vim.api.nvim_buf_create_user_command(
  0,
  "RacoTest",
  "2TermExec direction=float cmd='raco test %:p; " .. extra .. "'",
  { nargs = 0 }
)
