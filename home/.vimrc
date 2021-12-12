
let g:mapleader=","

" fonts and other gui stuff
" make sure to install the powerline patched font
" version of the font you like
" https://github.com/Lokaltog/powerline-fonts
if has("gui_running")
  set guioptions-=T " remove toolbar
  set guioptions-=r " remove right-hand scroll bar
  set guioptions-=L " remove left-hand scroll bar

  " activates ligatures when supported
  set macligatures

  try
    set guifont="JetBrains Mono:h16"
  catch
  endtry
endif

" Some plugins might have sudden bugs with fish. This fixes that.
set shell=bash
" Recently vim can merge signcolumn and number column into one
set signcolumn=number

" adds possibility of using 256 colors
set termguicolors
set t_8b=^[[48;2;%lu;%lu;%lum
set t_8f=^[[38;2;%lu;%lu;%lum
set t_Co=256
set t_ut=

" for the dark version
set background=dark

" default indent settings
set expandtab
set tabstop=2
set softtabstop=2
set shiftwidth=2
set shiftround

set autoread
set nobackup
set nowritebackup
set noswapfile
set visualbell
set noerrorbells
set encoding=utf-8
set scrolloff=8
set autoindent
set copyindent
set title
set showmode
set showcmd
set hidden
set ruler
set lazyredraw
" allows colors on long lines
set synmaxcol=5000
" allow backspacing over everything in insert mode
set backspace=indent,eol,start
" font line-height
set linespace=0
" adds line numbers to the left
set number
" prevents delay while pressing esc on insert mode
set timeoutlen=500 ttimeoutlen=0
" uses OS clipboard if possible (check +clipboard)
set clipboard^=unnamed,unnamedplus

" store lots of :cmdline history
set history=1000
" mark the ideal max text width
set colorcolumn=80

" some stuff to get the mouse going in term
set mouse=a

" keep going up dirs until a tags file is found
set tags=tags;/

" enable ctrl-n and ctrl-p to scroll thru matches
set wildmenu
" make cmdline tab completion similar to bash
set wildmode=longest:full,full
" ignored files while searching files and stuff
set wildignore+=*.so,*.dll,*.exe,*.zip,*.tar,*.gz,*.swf
set wildignore+=*.swp,*.swo,*~,*.pyc
set wildignore+=*.psd,*.png,*.gif,*.jpeg,*.jpg,*.pdf
set wildignore+=*/.git/*,*/.hq/*,*/.svn/*,*/tmp/*
set wildignore+=*/.sass-cache/*
set wildignore+=*/submodules/*,*/custom_modules/*
set wildignore+=tags
set wildignore+=*.i,*.d,*.sql3 "other exotic extensions

" ignores case
set ignorecase
" do not ignore case if explicitly defined on the search
" by search for an uppercased pattern
set smartcase
" defaults to search for every match of the pattern
set gdefault
set showmatch

" dont wrap lines
" set wrap
" " wrap lines at convenient points
set linebreak
set textwidth=360
set formatoptions=qrn1

" display tabs and trailing spaces
set list
set listchars=tab:▸\ ,eol:¬

" folding options
set foldmethod=indent
set nofoldenable

set jumpoptions+=stack

" turn on syntax highlighting
syntax on

nnoremap j gj
nnoremap k gk

" moves cursor faster
nnoremap <DOWN> 12j
vnoremap <DOWN> 12j
nnoremap <UP> 12k
vnoremap <UP> 12k

" moves the cursor around the buffer windows
nnoremap <LEFT> <C-w>h
nnoremap <RIGHT> <C-w>l

inoremap jj <ESC>
nnoremap ; :
vnoremap ; :

" makes ctrl-v work on command-line and search modes
cnoremap <C-v> <C-r>"
snoremap <C-v> <C-r>"

nnoremap <LEADER>ev :e $MYVIMRC<CR>
nnoremap <LEADER>sv :so $MYVIMRC<CR>
nnoremap <LEADER>v :vsplit<CR><C-w>l

" changes the size of the buffer windows
nnoremap = <C-w>=
nnoremap + :vertical resize +5<CR>
nnoremap - :vertical resize -5<CR>

" tab related mappings
nnoremap <LEADER>tc :tabnew<CR>
nnoremap <LEADER>tp :tabprevious<CR>
nnoremap <LEADER>tn :tabnext<CR>

" avoid going on ex mode
nnoremap Q <NOP>

" copies current buffer file path to register
nnoremap cp :let @+=resolve(fnamemodify(expand("%"), ":~:."))<CR>

" Keeps selection when changing indentation
" https://github.com/mhinz/vim-galore#dont-lose-selection-when-shifting-sidewards
xnoremap < <gv
xnoremap > >gv

" Disable cursorline highlight on insert mode
" https://github.com/mhinz/vim-galore#smarter-cursorline
autocmd InsertLeave,WinEnter * set cursorline
autocmd InsertEnter,WinLeave * set nocursorline

lua <<EOF
if vim.g.vscode == nil then
  require('init')
end
EOF


" starts terminal mode on insert mode
" disables line numbers on a newly opened terminal window (not really working)
" autocmd TermOpen term://* startinsert | setlocal nonumber
" close terminal buffer without showing the exit status of the shell
" autocmd TermClose term://* call feedkeys("\<cr>")
" tnoremap <Esc> <C-\><C-n>


fun! _CodeHubGetLineRange(mode)
  if a:mode == 'n'
    return line('.')
  endif
  let start_line = line("'<")
  let end_line = line("'>")
  if end_line == 0
    return start_line
  endif
  return start_line . '-' . end_line
endfun

fun! _CodeHubGetURL(mode)
  let BASE_URL = 'https://www.internalfb.com/code/'
  " TODO: maybe we can ge this from the remote URL?
  let repo = 'whatsapp-wajs'
  let git_path_prefix = trim(system('git rev-parse --show-prefix'))
  let line_range = _CodeHubGetLineRange(a:mode)
  " echo line_range
  " echo 'mode ' . mode()
  let local_path = resolve(fnamemodify(expand("%"), ":~:."))
  let url = BASE_URL . repo . '/' . git_path_prefix . local_path . '?lines=' . line_range
  return url
endfun

fun! CodeHubGetURL(mode)
  let url = _CodeHubGetURL(a:mode)
  echo 'copied ' . url
  return url
endfun

fun! CodeHubOpenFile(mode)
  let url = _CodeHubGetURL(a:mode)
  execute "silent !open '" . url . "'"
endfun

nnoremap <LEADER>hg :call CodeHubOpenFile('n')<CR>
vnoremap <LEADER>hg :<C-U>call CodeHubOpenFile('v')<CR>
nnoremap <LEADER>hc :let @+=CodeHubGetURL('n')<CR>
vnoremap <LEADER>hc :<C-U>let @+=CodeHubGetURL('v')<CR>


fun! SourceIfExists(file)
  if filereadable(expand(a:file))
    exe 'source' a:file
  endif
endfun

call SourceIfExists($HOME . '/.fb-vimrc')


filetype plugin indent on
