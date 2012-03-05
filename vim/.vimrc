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
Bundle 'scrooloose/syntastic'
Bundle 'kien/ctrlp.vim'
Bundle 'scrooloose/nerdcommenter'
Bundle 'sukima/xmledit'
Bundle 'scrooloose/nerdtree'
Bundle 'Shougo/neocomplcache'
Bundle 'othree/eregex.vim'
Bundle 'ciaranm/detectindent'
Bundle 'mileszs/ack.vim'
Bundle 'YankRing.vim'
Bundle 'mattn/zencoding-vim'
Bundle 'pangloss/vim-javascript'
Bundle 'tpope/vim-haml'
Bundle 'tpope/vim-surround'
Bundle 'tpope/vim-repeat'
Bundle 'kchmck/vim-coffee-script'
Bundle 'thomd/vim-jasmine'
Bundle 'groenewege/vim-less'
Bundle 'digitaltoad/vim-jade'
Bundle 'ajf/puppet-vim'
Bundle 'cakebaker/scss-syntax.vim'
Bundle 'robhudson/snipmate_for_django'


syntax on
filetype plugin indent on

" autodetects if the file uses spaces or tabs to define preferences
let g:detectindent_preferred_indent = 4
let g:detectindent_preferred_expandtab = 1
autocmd BufReadPost * :DetectIndent

let g:neocomplcache_enable_at_startup = 1

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
set number

if exists("&undofile")
  set undofile
endif

let mapleader = ","

nnoremap / :M/
vnoremap / :M/
nnoremap ? :M?
vnoremap ? :M?
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
nnoremap <leader>es :source $MYVIMRC<cr>
nnoremap <leader>w :let _s=@/<Bar>:%s/\s\+$//e<Bar>:let @/=_s<Bar>:nohl<CR>''
nnoremap <leader>W <C-w>v<C-w>l
nnoremap <leader>a :Ack
"html fold tag
nnoremap <leader>ft Vatzf
"sorts properties inside {} mostly for css
nnoremap <leader>S ?{<CR>jV/^\s*\}?$<CR>k:sort<CR>:noh<CR>

nnoremap <C-h> <C-w>h
nnoremap <C-l> <C-w>l

nnoremap <C-j> :m+<CR>==
nnoremap <C-k> :m-2<CR>==
inoremap <C-j> <Esc>:m+<CR>==gi
inoremap <C-k> <Esc>:m-2<CR>==gi
vnoremap <C-j> :m'>+<CR>gv=gv
vnoremap <C-k> :m-2<CR>gv=gv

noremap <leader>z :NERDTreeToggle<CR>

let g:ctrlp_map = '<leader>t'
nmap <silent> <leader>y <leader>t<F5><CR>

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

let g:syntastic_enable_signs=1
let g:syntastic_auto_loc_list=2


" Show trailing whitespace:
highlight ExtraWhitespace ctermbg=darkred guibg=darkred
match ExtraWhitespace /\s\+$/

