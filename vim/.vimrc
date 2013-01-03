colorscheme molokai
syntax on

let mapleader = ","

" try setting a better font
if has("gui_running")
  try
    set guifont=Monaco:h14
  catch
    try
      set guifont=SourceCodePro-Regular:h14
    catch
      set guifont=Inconsolata:h16
    endtry
  endtry
endif
set guioptions-=T  "remove toolbar
set guioptions-=r  "remove right-hand scroll bar
set guioptions-=L  "remove left-hand scroll bar

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
set linespace=0
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
nnoremap <D-j> 12j
nnoremap <D-k> 12k
vnoremap <D-j> 12j
vnoremap <D-k> 12k

inoremap jj <ESC>
nnoremap ; :

nnoremap <LEADER>ev <C-w><C-v><C-l>:e $MYVIMRC<CR>
nnoremap <LEADER>sv :so $MYVIMRC<CR>
nnoremap <LEADER>W a<ESC><Bar>:%s/\s\+$//<Bar><CR>``:noh<CR>
nnoremap <LEADER>w <C-w>v<C-w>l
nnoremap <LEADER>a :Ack<Space>

nnoremap <C-h> <C-w>h
nnoremap <C-l> <C-w>l
nnoremap = <C-w>=
nnoremap + :vertical resize +5<CR>
nnoremap - :vertical resize -5<CR>

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

vnoremap <LEADER>j :!python -m json.tool<CR>

filetype off

set rtp+=~/.vim/bundle/vundle/
call vundle#rc()

" let Vundle manage Vundle
" required!
Bundle 'gmarik/vundle'

Bundle 'Gundo'
Bundle 'YankRing.vim'

" vim-snipmate
Bundle 'MarcWeber/vim-addon-mw-utils'
Bundle 'tomtom/tlib_vim'
Bundle 'garbas/vim-snipmate'
Bundle 'honza/snipmate-snippets'
"/vim-snipmate

Bundle 'scrooloose/syntastic'
Bundle 'kien/ctrlp.vim'
Bundle 'davidhalter/jedi-vim'
Bundle 'scrooloose/nerdcommenter'
Bundle 'scrooloose/nerdtree'
Bundle 'Shougo/neocomplcache'
Bundle 'othree/eregex.vim'
Bundle 'mileszs/ack.vim'
Bundle 'mattn/zencoding-vim'
Bundle 'tpope/vim-fugitive'
Bundle 'pangloss/vim-javascript'
Bundle 'tpope/vim-haml'
Bundle 'tpope/vim-surround'
Bundle 'tpope/vim-repeat'
Bundle 'kchmck/vim-coffee-script'
Bundle 'thomd/vim-jasmine'
Bundle 'groenewege/vim-less'
Bundle 'digitaltoad/vim-jade'
Bundle 'briancollins/vim-jst'
Bundle 'cakebaker/scss-syntax.vim'
Bundle 'plasticboy/vim-markdown'
Bundle 'hostsamurai/CSSMinister.vim'
Bundle 'Lokaltog/vim-powerline'
"Bundle 'sjbach/lusty'

filetype plugin indent on

let g:neocomplcache_enable_at_startup=1
if !exists('g:neocomplcache_omni_functions')
    let g:neocomplcache_omni_functions = {}
endif
let g:neocomplcache_omni_functions['python'] = 'jedi#complete'
let g:jedi#popup_on_dot = 0

noremap <LEADER>z :NERDTreeToggle<CR>

nnoremap <C-z> :call zencoding#expandAbbr(0,"")<CR>a
inoremap <C-z> <ESC>:call zencoding#expandAbbr(0,"")<CR>a

"ctrlp
let g:ctrlp_map='<LEADER><LEADER>'
let g:ctrlp_max_height=20
nmap <LEADER>y :CtrlPClearCache<CR>

set wildignore+=*.so,*.dll,*.exe,*.zip,*.tar,*.gz
set wildignore+=*.swp,*.swo,*~,*.pyc
set wildignore+=*.psd,*.png,*.gif,*.jpeg,*.jpg
set wildignore+=*/.git/*,*/.hq/*,*/.svn/*,*/tmp/*
set wildignore+=*/.sass-cache/*,*/node_modules/*

let g:syntastic_check_on_open=1
let g:syntastic_enable_signs=1
let g:syntastic_auto_loc_list=2
" yipits ignored checks
let g:syntastic_python_checker_args="--ignore=E501,E502,W293,E121,E123,E124,E125,E126,E127,E128"
let g:syntastic_error_symbol='✗'
let g:syntastic_warning_symbol='⚠'

let g:Powerline_symbols = 'fancy'

"statusline
set statusline=%F%m%r%h%w%=(%{&ff}/%Y)\ (line\ %l\/%L,\ col\ %c)
set statusline+=%#warningmsg#
set statusline+=%{fugitive#statusline()}
set statusline+=%{SyntasticStatuslineFlag()}
set statusline+=%*

let g:yankring_history_file='.yankring_history'

set foldmethod=indent
set nofoldenable
nnoremap <SPACE> za
vnoremap <SPACE> zf

" underline to camelcase
vnoremap <LEADER>tcc :s#_\(\l\)#\u\1#<CR>:noh<CR>
" camelcase to underline
vnoremap <LEADER>tus :s#\([a-z0-9]\+\)\(\u\)#\l\1_\l\2#g<CR>:noh<CR>

" a better htmldjango detection
augroup filetypedetect

  " removes current htmldjango detection located at $VIMRUNTIME/filetype.vim
  au! BufNewFile,BufRead *.html
  au  BufNewFile,BufRead *.html   call FThtml()

  fun! FThtml()
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
  endfun
augroup END

" correctly indents the current file depending on the user options
nnoremap <LEADER>fi :retab<CR>
nnoremap <LEADER>ti :call ToggleIndentation()<CR>
nnoremap <LEADER>di :call NaiveIndentationDetector()<CR>

fun! ToggleIndentation()
    if &expandtab
        set noexpandtab
        echo "using tabs to indent"
    else
        set expandtab
        echo "using spaces to indent"
    endif
endfun

" sets expandtab based on the first
" indented lines of a file
fun! NaiveIndentationDetector()
    let n = 1
    let max_line_number = 10
    while n < max_line_number && n < line("$")
        let current_line = getline(n)
        if current_line =~ '^\t'
            set noexpandtab
            echo "using tabs to indent"
            return
        endif
        if current_line =~ '^ '
            set expandtab
            echo "using spaces to indent"
            return
        endif
        let n = n + 1
    endwhile
    echo "couldn't detect indentation based on the first ".max_line_number." lines of this file."
endfun

