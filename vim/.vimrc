colorscheme molokai
syntax on

let mapleader = ","

if has("gui_running")
  set guifont=Inconsolata:h16
endif
set guioptions-=T  "remove toolbar
set guioptions-=r  "remove right-hand scroll bar

set nocompatible
set modelines=0

set expandtab
set tabstop=4
set softtabstop=4
set shiftwidth=4
set shiftround

set autoread
set nobackup
set noswapfile
set visualbell
set noerrorbells
set encoding=utf-8
set scrolloff=3
set autoindent
set copyindent
set title
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

"search related {{{
nnoremap / /\v
vnoremap / /\v
set ignorecase
set smartcase
set gdefault
set showmatch
set hlsearch
set incsearch
"clears search
nnoremap <LEADER><SPACE> :noh<CR>
nnoremap <TAB> %
vnoremap <TAB> %
" }}}

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
nnoremap <LEADER>sv :so $MYVIMRC<CR>
nnoremap <LEADER>W a<ESC>:let _s=@/<Bar>:%s/\s\+$//<Bar>:let @/=_s<CR>``
nnoremap <LEADER>w <C-w>v<C-w>l
nnoremap <LEADER>a :Ack<Space>

nnoremap <C-h> <C-w>h
nnoremap <C-l> <C-w>l

nnoremap <C-j> :m+<CR>==
nnoremap <C-k> :m-2<CR>==
inoremap <C-j> <ESC>:m+<CR>==gi
inoremap <C-k> <ESC>:m-2<CR>==gi
vnoremap <C-j> :m'>+<CR>gv=gv
vnoremap <C-k> :m-2<CR>gv=gv

"show trailing whitespace
highlight ExtraWhitespace ctermbg=darkred guibg=darkred
match ExtraWhitespace /\s\+$/

cmap w!! w !sudo tee % >/dev/null

vnoremap <Leader>j :!python -m json.tool<CR>

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
Bundle 'hostsamurai/CSSMinister.vim'
"Bundle 'sjbach/lusty'
Bundle 'pavel-v-chernykh/vim-vagrant.git'

filetype plugin indent on

let g:neocomplcache_enable_at_startup=1

noremap <LEADER>z :NERDTreeToggle<CR>

nnoremap <C-z> :call zencoding#expandAbbr(0,"")<CR>a
inoremap <C-z> <ESC>:call zencoding#expandAbbr(0,"")<CR>a

"removes autodetection of indentation on TAB
"au! YAIFA
map <LEADER>di :YAIFAMagic<CR>

"ctrlp
let g:ctrlp_map='<LEADER>t'
let g:ctrlp_max_height=20
nmap <LEADER>y :CtrlPClearCache<CR>

set wildignore+=*.so,*.dll,*.exe,*.zip,*.tar,*.gz
set wildignore+=*.swp,*.swo,*~,*.pyc
set wildignore+=*.psd,*.png,*.gif,*.jpeg,*.jpg
set wildignore+=*/.git/*,*/.hq/*,*/.svn/*,*/tmp/*,*/.sass-cache/*
set wildignore+=*/node_modules/*

let g:syntastic_check_on_open=1
let g:syntastic_enable_signs=1
let g:syntastic_auto_loc_list=2
" yipits ignored checks
let g:syntastic_python_checker_args="--ignore=E501,E502,W293,E121,E123,E124,E125,E126,E127,E128"

"statusline
set statusline=%F%m%r%h%w%=(%{&ff}/%Y)\ (line\ %l\/%L,\ col\ %c)
set statusline+=%#warningmsg#
set statusline+=%{SyntasticStatuslineFlag()}
set statusline+=%*

let g:yankring_history_file='.yankring_history'

" a better htmldjango detection
augroup filetypedetect
  " removes current htmldjango detection located at $VIMRUNTIME/filetype.vim
  au! BufNewFile,BufRead *.html
  au  BufNewFile,BufRead *.html   call FThtml()

  func! FThtml()
    let n = 1
    while n < 10 && n < line("$")
      if getline(n) =~ '{%\|{{\|{#'
        setf htmldjango
        return
      endif
      let n = n + 1
    endwhile

    let n = 1
    while n < 10 && n < line("$")
      if getline(n) =~ '\<DTD\s\+XHTML\s'
        setf xhtml
        return
      endif
      let n = n + 1
    endwhile
    setf html
  endfunc
augroup END


" correctly indents the current file depending on the user options
nnoremap <LEADER>fi a<ESC>:let _s=@/<BAR>:call MyFixIndentation()<BAR>:let @/=_s<CR>``

function! MyFixIndentation()
  let spaces = ''
  let tab = '\t'
  for i in range(&shiftwidth)
    let spaces .= ' '
  endfor

  if exists('&expandtab')
    let incorrectIndentation = tab
    let correctIndentation = spaces
  else
    let incorrectIndentation = spaces
    let correctIndentation = tab
  endif

  try
    execute "% s/" . incorrectIndentation . "/" . correctIndentation . "/"
  catch
    echo "Indentation is fine already."
  endtry
endfunction

noh
