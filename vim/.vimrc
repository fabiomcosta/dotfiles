syntax on

let mapleader = ","

" try setting a better font
if has("gui_running")
  colorscheme molokai "molokai is better only on mvim
  set guioptions-=T   "remove toolbar
  set guioptions-=r   "remove right-hand scroll bar
  set guioptions-=L   "remove left-hand scroll bar
  try
    set guifont=Monaco:h14
  catch
    try
      set guifont=SourceCodePro-Regular:h14
    catch
      set guifont=Inconsolata:h16
    endtry
  endtry
else
  colorscheme slate
endif

set nocompatible
set modelines=0

set expandtab
set tabstop=2
set softtabstop=2
set shiftwidth=2
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
" Use control+up/down to move fast
nnoremap <C-j> 12j
nnoremap <C-k> 12k
vnoremap <C-j> 12j
vnoremap <C-k> 12k

inoremap jj <ESC>
nnoremap ; :

nnoremap <LEADER>ev <C-w><C-v><C-l>:e $MYVIMRC<CR>
nnoremap <LEADER>sv :so $MYVIMRC<CR>
nnoremap <LEADER>W a<ESC><Bar>:%s/\s\+$//<Bar><CR>``:noh<CR>
nnoremap <LEADER>w :vsplit<CR><C-w>l
nnoremap <LEADER>v :split<CR><C-w>j
nnoremap <LEADER>a :Ack<Space>

" moves the cursor around the buffer windows
nnoremap <C-h> <C-w>h
nnoremap <C-l> <C-w>l
"nnoremap <C-j> <C-w>j
"nnoremap <C-k> <C-w>k

" changes the size of the buffer windows
nnoremap = <C-w>=
nnoremap + :vertical resize +5<CR>
nnoremap - :vertical resize -5<CR>

"show trailing whitespace
highlight ExtraWhitespace ctermbg=darkred guibg=darkred
match ExtraWhitespace /\s\+$/

cmap w!! w !sudo tee % >/dev/null

vnoremap <LEADER>j :!python -m json.tool<CR>

filetype off

if has('vim_starting')
  set runtimepath+=~/.vim/bundle/neobundle.vim/
endif

call neobundle#rc(expand('~/.vim/bundle/'))

" Let NeoBundle manage NeoBundle
NeoBundleFetch 'Shougo/neobundle.vim'

NeoBundle 'Gundo'
NeoBundle 'YankRing.vim'

" vim-snipmate
NeoBundle 'MarcWeber/vim-addon-mw-utils'
NeoBundle 'tomtom/tlib_vim'
NeoBundle 'garbas/vim-snipmate'
NeoBundle 'honza/vim-snippets'
"/vim-snipmate

NeoBundle 'scrooloose/syntastic'
NeoBundle 'kien/ctrlp.vim'
"NeoBundle 'davidhalter/jedi-vim'
NeoBundle 'scrooloose/nerdcommenter'
NeoBundle 'scrooloose/nerdtree', {'augroup': 'NERDTreeHijackNetrw'}
NeoBundle 'Shougo/neocomplcache'
NeoBundle 'othree/eregex.vim'
NeoBundle 'mileszs/ack.vim'
NeoBundle 'mattn/zencoding-vim'
NeoBundle 'tpope/vim-fugitive', {'augroup': 'fugitive'}
NeoBundle 'pangloss/vim-javascript'
NeoBundle 'tpope/vim-haml'
NeoBundle 'tpope/vim-surround'
NeoBundle 'tpope/vim-repeat'
NeoBundle 'kchmck/vim-coffee-script'
NeoBundle 'thomd/vim-jasmine'
NeoBundle 'groenewege/vim-less'
NeoBundle 'digitaltoad/vim-jade'
NeoBundle 'briancollins/vim-jst'
NeoBundle 'cakebaker/scss-syntax.vim'
NeoBundle 'plasticboy/vim-markdown'
NeoBundle 'hostsamurai/CSSMinister.vim'
NeoBundle 'Lokaltog/vim-powerline'
NeoBundle 'airblade/vim-gitgutter'
NeoBundle 'Lokaltog/vim-easymotion'
NeoBundle 'godlygeek/tabular'
"NeoBundle 'sjbach/lusty'
NeoBundle 'hack-stable', {'type': 'nosync'}

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
let g:syntastic_python_flake8_args="--ignore=E501,E502,W293,E121,E123,E124,E125,E126,E127,E128"
let g:syntastic_error_symbol='✗'
let g:syntastic_warning_symbol='⚠'

let g:Powerline_symbols = 'fancy'

" statusline
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
nnoremap <LEADER>tit :call ToggleIndentationType()<CR>
nnoremap <LEADER>tis :call ToggleIndentationSize()<CR>
nnoremap <LEADER>di :call NaiveIndentationDetector()<CR>

fun! ToggleIndentationSize()
    let n = 4
    if &shiftwidth == 4
        let n = 2
    endif

    let &tabstop=n
    let &softtabstop=n
    let &shiftwidth=n
    echo "indentation width is now ".n."."
endfun

fun! ToggleIndentationType()
    if &expandtab
        set noexpandtab
        echo "using tabs to indent."
    else
        set expandtab
        echo "using spaces to indent."
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
            echo "using tabs to indent."
            return
        endif
        if current_line =~ '^ '
            set expandtab
            echo "using spaces to indent."
            return
        endif
        let n = n + 1
    endwhile
    echo "couldn't detect indentation based on the first ".max_line_number." lines of this file."
endfun

" Installation check.
NeoBundleCheck
