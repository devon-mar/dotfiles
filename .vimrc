" Specify a directory for plugins
call plug#begin('~/.vim/plugged')
Plug 'luochen1990/rainbow'
Plug 'octol/vim-cpp-enhanced-highlight'
Plug 'whatyouhide/vim-lengthmatters'
Plug 'fatih/vim-go'
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
Plug 'ntpeters/vim-better-whitespace'
Plug 'Yggdroot/indentLine'
Plug 'editorconfig/editorconfig-vim'
" color scheme
Plug 'fratajczak/one-monokai-vim'
call plug#end()

" rainbow plugin
let g:rainbow_active = 1

set textwidth=120
set nocompatible

" Make it look good
syntax on
colorscheme one-monokai
set termguicolors
" Fix windows terminal transparency
hi Normal guibg=NONE ctermbg=NONE
set tabstop=4
set shiftwidth=4
set softtabstop=4
filetype plugin on
set expandtab

set number


" Airline
let g:airline_powerline_fonts = 1
let g:airline_theme='powerlineish'

" clang-format
" map to <Leader>cf in C++ code
autocmd FileType c,cpp,objc nnoremap <buffer><Leader>cf :<C-u>ClangFormat<CR>
autocmd FileType c,cpp,objc vnoremap <buffer><Leader>cf :ClangFormat<CR>

let g:indentLine_char_list = ['|', '¦', '┆', '┊']

" yaml formatting
autocmd FileType yaml setlocal ts=2 sts=2 sw=2 expandtab
