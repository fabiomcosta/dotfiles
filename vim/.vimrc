colorscheme molokai

if has("gui_running")
  set guifont=Inconsolata:h14
endif

set nocompatible
filetype off

set rtp+=~/.vim/bundle/vundle/
call vundle#rc()

" let Vundle manage Vundle
" required! 
Bundle 'gmarik/vundle'

Bundle 'snipMate'
Bundle 'kien/ctrlp.vim'
Bundle 'tpope/vim-haml'
Bundle 'tpope/vim-surround'
Bundle 'tpope/vim-repeat'
Bundle 'kchmck/vim-coffee-script'
Bundle 'scrooloose/syntastic'
Bundle 'csexton/snipmate.vim'
Bundle 'scrooloose/nerdcommenter'
Bundle 'ajf/puppet-vim'
Bundle 'sukima/xmledit'
Bundle 'scrooloose/nerdtree'
Bundle 'pangloss/vim-javascript'
Bundle 'ervandew/supertab'
Bundle 'thomd/vim-jasmine'
Bundle 'groenewege/vim-less'
Bundle 'digitaltoad/vim-jade'
Bundle 'othree/eregex.vim'
Bundle 'cakebaker/scss-syntax.vim'
Bundle 'ciaranm/detectindent'
Bundle 'robhudson/snipmate_for_django'
Bundle 'mileszs/ack.vim'

syntax on
filetype plugin indent on

" autodetects if the file uses spaces or tabs to define preferences
:autocmd BufReadPost * :DetectIndent
:let g:detectindent_preferred_indent = 4
:let g:detectindent_preferred_expandtab = 1

set modelines=0

set tabstop=4
set shiftwidth=4
set softtabstop=4
set expandtab

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
set undofile
set number

let mapleader = ","

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
set formatoptions=qrn1

nmap <leader>l :set list!<CR>
set list
set listchars=tab:▸\ ,eol:¬

au FocusLost * :wa

nnoremap j gj
nnoremap k gk

inoremap jj <ESC>
nnoremap ; :

nnoremap <leader>ev <C-w><C-v><C-l>:e $MYVIMRC<cr>
nnoremap <leader>w <C-w>v<C-w>l
nnoremap <leader>a :Ack
"html fold tag
nnoremap <leader>ft Vatzf
"sorts properties inside {} mostly for css
nnoremap <leader>S ?{<CR>jV/^\s*\}?$<CR>k:sort<CR>:noh<CR>

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

nnoremap <leader>W :%s/\s\+$//<cr>:let @/=''<CR>
map <F3> :NERDTreeToggle<CR>

set statusline=%F%m%r%h%w%=(%{&ff}/%Y)\ (line\ %l\/%L,\ col\ %c)
set statusline+=%#warningmsg#
set statusline+=%{SyntasticStatuslineFlag()}
set statusline+=%*

au BufNewFile,BufRead *.less set filetype=less

set guioptions-=T  "remove toolbar
set guioptions-=r  "remove right-hand scroll bar

augroup mkd
    autocmd BufRead,BufEnter *.mkd set ai formatoptions=tcroqn2 comments=n:&gt;
    autocmd BufRead,BufEnter *.md set ai formatoptions=tcroqn2 comments=n:&gt;
    autocmd BufRead,BufEnter *.markdown set ai formatoptions=tcroqn2 comments=n:&gt;
augroup END

nmap <silent> <Leader>y :CommandTFlush<CR>
nmap <silent> <Leader>t :CommandT<CR>

let g:syntastic_enable_signs=1
let g:syntastic_auto_loc_list=2

nnoremap / :M/
nnoremap ? :M?
nnoremap ,/ /
nnoremap ,? ?

