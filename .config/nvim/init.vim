if &compatible
  set nocompatible               " Be iMproved
endif
set runtimepath+=/home/bb010g/.local/dein/repos/github.com/Shougo/dein.vim

if dein#load_state('/home/bb010g/.local/dein')
  call dein#begin('/home/bb010g/.local/dein')

  " Let dein manage dein
  call dein#add('/home/bb010g/.local/dein/repos/github.com/Shougo/dein.vim')

  " Add or remove your plugins here:
  call dein#add('itchyny/lightline.vim')
  call dein#add('junegunn/goyo.vim', {'on_cmd': 'Goyo'})
  call dein#add('Shougo/denite.nvim', {'on_cmd': ['Denite', 'DeniteBufferDir', 'DeniteCursorWord', 'DeniteProjectDir']})
  call dein#add('Shougo/deol.nvim', {'on_cmd': ['Deol', 'DeolCd', 'DeolEdit']})
  call dein#add('Shougo/deoplete.nvim', {'on_event': 'InsertEnter'})
  call dein#add('Shougo/junkfile.vim', {'on_cmd': 'JunkfileOpen'})
  call dein#add('Shougo/neosnippet.vim', {'on_event': 'InsertEnter'})
  call dein#add('Shougo/neosnippet-snippets', {'depends': 'neosnippet.vim'})
  call dein#add('Shougo/vinarise.vim', {'on_cmd': 'Vinarise'})
  call dein#add('tpope/vim-characterize', {'on_map': {'n': ['ga']}})
  call dein#add('tpope/vim-commentary', {'on_map': {'nxo': ['gc']}, 'on_command': 'Commentary', 'depends': 'vim-repeat'})
  call dein#add('tpope/vim-eunuch')
  call dein#add('tpope/vim-repeat', {'on_map': '.'})
  call dein#add('tpope/vim-surround', {'on_map': {'n': ['cs', 'ds', 'ys'], 'x': 'S'}, 'depends': 'vim-repeat'})

  " theme
  call dein#add('guns/xterm-color-table.vim', {'on_cmd': 'XtermColorTable'})
  call dein#add('https://github.com/dracula/vim', {'name': 'dracula'})

  " deoplete completions
  call dein#add('fszymanski/deoplete-emoji', {'depends': 'deoplete.nvim', 'lazy': 1, 'on_event': 'InsertEnter'})
  call dein#add('Shougo/neco-syntax', {'depends': 'deoplete.nvim', 'lazy': 1, 'on_event': 'InsertEnter'})
  call dein#add('Shougo/neco-vim', {'depends': 'deoplete.nvim', 'lazy': 1, 'on_event': 'InsertEnter', 'on_if': '&filetype == "vim"'})
  call dein#add('zchee/deoplete-clang', {'depends': 'deoplete.nvim', 'lazy': 1, 'on_event': 'InsertEnter', 'on_if': 'count(["c", "cpp", "objc"], &filetype)'})
  call dein#add('zchee/deoplete-zsh', {'depends': 'deoplete.nvim', 'lazy': 1, 'on_event': 'InsertEnter', 'on_if': '&filetype == "zsh"'})

  call dein#end()
  call dein#save_state()
endif

filetype plugin indent on
syntax enable
set termguicolors
color dracula

set tabstop=8 " visual <TAB>
set softtabstop=4 " tab key
set shiftwidth=4 " actual tab key
set expandtab " tabs as spaces
set smarttab " more tabs as spaces

set number " current line number
set relativenumber " relative line numbers elsewhere
set showcmd " show last command in bottom right
set cursorline " highlight current line

set wildmenu " visual command autocomplete

set foldenable
set foldlevelstart=10
set foldnestmax=10
set foldmethod=indent

let mapleader = ','

if executable('rg')
  set grepprg=rg\ --vimgrep
endif

" Plugin config

" deoplete
let g:deoplete#enable_at_startup = 1
" deoplete: deoplete-clang
let g:deoplete#sources#clang#libclang_path = '/usr/lib/libclang.so'
let g:deoplete#sources#clang#clang_header = '/usr/lib/clang'
" deoplete: Eclim
let g:EclimCompletionMethod = 'omnifunc'

" lightline
let g:lightline = {
  \ 'colorscheme': 'Dracula',
  \ }

" Terminal colors

" normal colors
let g:terminal_color_0 = '#000000'
let g:terminal_color_1 = '#ff5555'
let g:terminal_color_2 = '#50fa7b'
let g:terminal_color_3 = '#f1fa8c'
let g:terminal_color_4 = '#bd93f9'
let g:terminal_color_5 = '#ff79c6'
let g:terminal_color_6 = '#8be9fd'
let g:terminal_color_7 = '#bfbfbf'

" bright colors
let g:terminal_color_8 = '#4d4d4d'
let g:terminal_color_9 = '#ff6e67'
let g:terminal_color_10 = '#5af78e'
let g:terminal_color_11 = '#f4f99d'
let g:terminal_color_12 = '#caa9fa'
let g:terminal_color_13 = '#ff92d0'
let g:terminal_color_14 = '#9aedfe'
let g:terminal_color_15 = '#e6e6e6'
