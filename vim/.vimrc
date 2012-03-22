colorscheme molokai

if has("gui_running")
  set guifont=Inconsolata:h14
endif

set nocompatible
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
nnoremap <LEADER><SPACE> :noh<CR>
nnoremap <TAB> %
vnoremap <TAB> %

set wrap
set textwidth=360
set formatoptions=qrn1

nmap <LEADER>l :set list!<CR>
set list
set listchars=tab:▸\ ,eol:¬

au FocusLost * :wa

nnoremap j gj
nnoremap k gk

inoremap jj <ESC>
nnoremap ; :

nnoremap <LEADER>ev <C-w><C-v><C-l>:e $MYVIMRC<CR>
nnoremap <LEADER>es :source $MYVIMRC<CR>
nnoremap <LEADER>w a<ESC>:let _s=@/<Bar>:%s/\s\+$//<Bar>:let @/=_s<Bar>:nohl<CR>``
nnoremap <LEADER>W <C-w>v<C-w>l
nnoremap <LEADER>a :Ack
"html fold tag
nnoremap <LEADER>ft Vatzf
"sorts properties inside {} mostly for css
nnoremap <LEADER>S ?{<CR>jV/^\s*\}?$<CR>k:sort<CR>:noh<CR>

nnoremap <C-h> <C-w>h
nnoremap <C-l> <C-w>l

nnoremap <C-j> :m+<CR>==
nnoremap <C-k> :m-2<CR>==
inoremap <C-j> <ESC>:m+<CR>==gi
inoremap <C-k> <ESC>:m-2<CR>==gi
vnoremap <C-j> :m'>+<CR>gv=gv
vnoremap <C-k> :m-2<CR>gv=gv

set guioptions-=T  "remove toolbar
set guioptions-=r  "remove right-hand scroll bar

"show trailing whitespace
highlight ExtraWhitespace ctermbg=darkred guibg=darkred
match ExtraWhitespace /\s\+$/


filetype off

set rtp+=~/.vim/bundle/vundle/
call vundle#rc()

" let Vundle manage Vundle
" required!
Bundle 'gmarik/vundle'

Bundle 'snipMate'
Bundle 'Gundo'
Bundle 'YankRing.vim'
Bundle 'yaifa.vim'

Bundle 'scrooloose/syntastic'
Bundle 'kien/ctrlp.vim'
Bundle 'scrooloose/nerdcommenter'
Bundle 'sukima/xmledit'
Bundle 'scrooloose/nerdtree'
Bundle 'Shougo/neocomplcache'
Bundle 'othree/eregex.vim'
Bundle 'mileszs/ack.vim'
Bundle 'mattn/zencoding-vim'
Bundle 'tpope/vim-fugitive'
Bundle 'robhudson/snipmate_for_django'
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
Bundle 'plasticboy/vim-markdown'


" autodetects if the file uses spaces or tabs to define preferences
autocmd BufReadPost * :DetectIndent

let g:neocomplcache_enable_at_startup=1

noremap <LEADER>z :NERDTreeToggle<CR>

inoremap <C-z> <ESC>:call zencoding#expandAbbr(0)<CR>a

"removes autodetection of indentation on TAB
au! YAIFA
map <LEADER>ii :YAIFAMagic<CR>

"ctrlp
let g:ctrlp_map = '<LEADER>t'
nmap <LEADER>y :CtrlPClearCache<cr>
let g:ctrlp_working_path_mode = 1
let g:ctrlp_max_height = 20
set wildignore+=*/tmp/*,*.so,*.swp,*.zip,*.un~,*.dll,*.exe
set wildignore+=*/.git/*,*/.hq/*,*/.svn/*,*/.sass-cache/*
set wildignore+=*.psd,*.png,*.gif,*.jpeg,*.jpg

"statusline
set statusline=%F%m%r%h%w%=(%{&ff}/%Y)\ (line\ %l\/%L,\ col\ %c)
set statusline+=%#warningmsg#
set statusline+=%{SyntasticStatuslineFlag()}
set statusline+=%*

let g:syntastic_check_on_open=1
let g:syntastic_enable_signs=1
let g:syntastic_auto_loc_list=2

let g:yankring_history_file='.yankring_history'


syntax on
filetype plugin indent on

