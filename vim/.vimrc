colorscheme blackboard

if has("gui_running")
  set guifont=Inconsolata:h18
endif

filetype off
call pathogen#runtime_append_all_bundles()
filetype plugin indent on

set nocompatible

set modelines=0

set tabstop=4
set shiftwidth=4
set softtabstop=4
set number
set expandtab

let mapleader = ","

set encoding=utf-8
set scrolloff=3
set autoindent
set showmode
set showcmd
set hidden
set wildmenu
set wildmode=list:longest
set cursorline
set ttyfast
set ruler
set backspace=indent,eol,start
set laststatus=2

nnoremap / /\v
vnoremap / /\v
set ignorecase
set smartcase
set gdefault
set incsearch
set showmatch
set hlsearch
nnoremap <leader><space> :noh<cr>
nnoremap <tab> %
vnoremap <tab> %

set wrap
set textwidth=360
set fuopt=maxvert,maxhorz
set formatoptions=qrn1

nmap <leader>l :set list!<CR>
set list
set listchars=tab:▸\ ,eol:¬

nnoremap <up> <nop>
nnoremap <down> <nop>
nnoremap <left> <nop>
nnoremap <right> <nop>
inoremap <up> <nop>
inoremap <down> <nop>
inoremap <left> <nop>
inoremap <right> <nop>
nnoremap j gj
nnoremap k gk

nnoremap ; :
au FocusLost * :wa

nnoremap <leader>ev <C-w><C-v><C-l>:e $MYVIMRC<cr>
nnoremap <leader>w <C-w>v<C-w>l

nnoremap <C-h> <C-w>h
nnoremap <C-j> <C-w>j
nnoremap <C-k> <C-w>k
nnoremap <C-l> <C-w>l

nnoremap <C-j> :m+<CR>==
nnoremap <C-k> :m-2<CR>==
inoremap <C-j> <Esc>:m+<CR>==gi
inoremap <C-k> <Esc>:m-2<CR>==gi
vnoremap <C-j> :m'>+<CR>gv=gv
vnoremap <C-k> :m-2<CR>gv=gv

set statusline=%F%m%r%h%w%=(%{&ff}/%Y)\ (line\ %l\/%L,\ col\ %c)

au BufNewFile,BufRead *.less set filetype=less

"set guioptions-=m  "remove menu bar
set guioptions-=T  "remove toolbar
set guioptions-=r  "remove right-hand scroll bar

augroup mkd
    autocmd BufRead,BufEnter *.mkd set ai formatoptions=tcroqn2 comments=n:&gt;
    autocmd BufRead,BufEnter *.md set ai formatoptions=tcroqn2 comments=n:&gt;
    autocmd BufRead,BufEnter *.markdown set ai formatoptions=tcroqn2 comments=n:&gt;
augroup END

nmap <silent> <Leader>y :CommandTFlush<CR>
nmap <silent> <Leader>t :CommandT<CR>

if !exists("*TrimWhiteSpace")
    " Removes trailing spaces
    function TrimWhiteSpace()
      %s/\s*$//
      ''
    :endfunction
endif

map <F2> :call TrimWhiteSpace()<CR>
map <F1> :tabnew<CR>

