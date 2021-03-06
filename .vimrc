" Specify a directory for plugins
call plug#begin('~/.vim/plugged')
Plug 'luochen1990/rainbow'
Plug 'octol/vim-cpp-enhanced-highlight'
Plug 'whatyouhide/vim-lengthmatters'
Plug 'fatih/vim-go'
Plug 'nathanaelkane/vim-indent-guides'
" color scheme
Plug 'fratajczak/one-monokai-vim'
call plug#end()

" rainbow plugin
let g:rainbow_active = 1
let g:indent_guides_enable_on_vim_startup = 1

set textwidth=120

set nocompatible
set termguicolors
syntax on
colorscheme one-monokai
" Don't change the background
hi Normal guibg=NONE ctermbg=NONE


set shiftwidth=4
set softtabstop=4
set smarttab
set expandtab
filetype plugin indent on

" powerline

python3 from powerline.vim import setup as powerline_setup
python3 powerline_setup()
python3 del powerline_setup
set laststatus=2 " Always display the statusline in all windows
set showtabline=2 " Always display the tabline, even if there is only one tab
set noshowmode " Hide the default mode text (e.g. -- INSERT -- below the statusline)
