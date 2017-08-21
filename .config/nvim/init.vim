if &compatible
  set nocompatible
endif
let s:dein_dir = '~/.local/dein'
execute 'set runtimepath+=~/.local/dein/repos/github.com/Shougo/dein.vim'

let mapleader = "\<Space>"
let maplocalleader = ","

augroup MyAutoCmd
augroup END

if dein#load_state(s:dein_dir)
    call dein#begin(s:dein_dir)

    call dein#load_toml('~/.config/nvim/dein.toml')
    call dein#load_toml('~/.config/nvim/dein-deo.toml')
    call dein#load_toml('~/.config/nvim/dein-ft.toml')

    call dein#end()
    call dein#save_state()
endif
call dein#call_hook('source')
call dein#call_hook('post_source')

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

set hidden " don't close buffers immediately

set foldenable
set foldlevelstart=10
set foldnestmax=10
set foldmethod=indent

if executable('rg')
  set grepprg=rg\ --vimgrep
endif

" Plugin config

" denite

let g:webdevicons_enable_denite = 0

" deoplete
" deoplete: deoplete-clang
let g:deoplete#sources#clang#libclang_path = '/usr/lib/libclang.so'
let g:deoplete#sources#clang#clang_header = '/usr/lib/clang'
" deoplete: Eclim
let g:EclimCompletionMethod = 'omnifunc'

" leader guide
let g:lmap = {}

let g:lmap.b = {'name': 'Buffers'}
    nnoremap <SID>(buffer-denite) :Denite buffer<CR>
    nmap <leader>bb <SID>(buffer-denite)
    nnoremap <SID>(buffer-delete) :bdelete<CR>
    nmap <leader>bd <SID>(buffer-delete)
    nnoremap <SID>(buffer-next) :bnext<CR>
    nmap <leader>bn <SID>(buffer-next)
    nnoremap <SID>(buffer-previous) :bprevious<CR>
    nmap <leader>bN <SID>(buffer-previous)
    nnoremap <SID>(buffer-scratch) :JunkfileOpen<CR>
    nmap <leader>bs <SID>(buffer-scratch)
    nnoremap <SID>(buffer-scratch-denite) :Denite junkfile<CR>
    nmap <leader>bS <SID>(buffer-scratch-denite)

let g:lmap.f = {'name': 'Files'}
    nnoremap <SID>(file-open-vimrc) :e ~/.config/nvim/init.vim<CR>
    nmap <leader>fd <SID>(file-open-vimrc)
    nnoremap <SID>(file-open-vimrc-dir) :e ~/.config/nvim/<CR>
    nmap <leader>fD <SID>(file-open-vimrc-dir)

let g:lmap.s = {'name': 'Search'}
    nnoremap <SID>(search-files) :Denite file_rec<CR>
    nmap <leader>sf <SID>(search-files)
    nnoremap <SID>(search-project-files) :DeniteProjectDir file_rec<CR>
    nmap <leader>sF <SID>(search-project-files)
    nnoremap <SID>(search-grep) :Denite grep<CR>
    nmap <leader>ss <SID>(search-grep)
    nnoremap <SID>(search-project-grep) :DeniteProjectDir grep<CR>
    nmap <leader>sS <SID>(search-project-grep)

let g:lmap.w = {'name': 'Windows'}
    nnoremap <SID>(window-focus-left) <c-w>h
    nmap <leader>wh <SID>(window-focus-left)
        nnoremap <SID>(window-move-left) <c-w>H
        nmap <leader>wH <SID>(window-move-left)
    nnoremap <SID>(window-focus-down) <c-w>j
    nmap <leader>wj <SID>(window-focus-down)
        nnoremap <SID>(window-move-down) <c-w>J
        nmap <leader>wJ <SID>(window-move-down)
    nnoremap <SID>(window-focus-up) <c-w>k
    nmap <leader>wk <SID>(window-focus-up)
        nnoremap <SID>(window-move-up) <c-w>K
        nmap <leader>wK <SID>(window-move-up)
    nnoremap <SID>(window-focus-right) <c-w>l
    nmap <leader>wl <SID>(window-focus-right)
        nnoremap <SID>(window-move-right) <c-w>L
        nmap <leader>wL <SID>(window-move-right)

    nnoremap <SID>(window-split) <c-w>s
    nmap <leader>ws <SID>(window-split)
    nnoremap <SID>(window-splitv) <c-w>v
    nmap <leader>wv <SID>(window-splitv)
    nnoremap <SID>(window-close) <c-w>c
    nmap <leader>wc <SID>(window-close)

let g:llmap = {}

let g:topdict = {}
let g:topdict[mapleader] = g:lmap
let g:topdict[mapleader]['name'] = '<Leader>'
let g:topdict[maplocalleader] = g:llmap
let g:topdict[maplocalleader]['name'] = '<LocalLeader>'

nnoremap <silent> <leader> :<c-u>LeaderGuide '<Space>'<CR>
vnoremap <silent> <leader> :<c-u>LeaderGuideVisual '<Space>'<CR>
map <leader>. <Plug>leaderguide-global
nnoremap <LocalLeader> :<c-u>LeaderGuide ','<CR>
vnoremap <LocalLeader> :<c-u>LeaderGuideVisual ','<CR>
map <Localleader>. <Plug>leaderguide-buffer

" lightline
let g:lightline = {
  \ 'colorscheme': 'Dracula',
  \ }

" lion
let g:lion_create_maps = 0
let g:lion_squeeze_spaces = 1 " disable with b:lion_squeeze_spaces

nmap <silent> gl <Plug>LionRight
vmap <silent> gl <Plug>VLionRight
nmap <silent> gL <Plug>LionLeft
vmap <silent> gL <Plug>VLionLeft

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
