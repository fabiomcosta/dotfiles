
let mapleader=","

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
set scrolloff=3
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
set wildignore+=*/custom_modules/*
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

" buffer navigation
nnoremap <C-b> :bp<CR>
nnoremap <C-n> :bn<CR>

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

" so vim won't force pep8 on all python files
let g:python_recommended_style=0

let data_dir = stdpath('data') . '/site'
if empty(glob(data_dir . '/autoload/plug.vim'))
  silent execute '!curl -fLo '.data_dir.'/autoload/plug.vim --create-dirs  https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

call plug#begin(expand('~/.local/share/nvim/plugged'))

Plug 'jordwalke/VimAutoMakeDirectory'
Plug 'tpope/vim-surround'
Plug 'tpope/vim-repeat'
Plug 'tpope/vim-sleuth'
Plug 'tpope/vim-fugitive', {'augroup': 'fugitive'}
Plug 'tpope/vim-commentary'
Plug 'styled-components/vim-styled-components', { 'branch': 'main' }
Plug 'moll/vim-node'
Plug 'hhvm/vim-hack'
Plug 'jparise/vim-graphql'
Plug 'christoomey/vim-tmux-navigator'
Plug 'editorconfig/editorconfig-vim'
" Plug 'godlygeek/tabular'
" Plug 'jeffkreeftmeijer/vim-numbertoggle'
" Plug 'w0rp/ale'


if !exists('g:vscode')

  Plug 'sheerun/vim-polyglot'
  let g:javascript_plugin_flow=1


  Plug 'othree/eregex.vim'
  let g:eregex_default_enable=0


  Plug 'haya14busa/incsearch.vim'
  set hlsearch
  let g:incsearch#auto_nohlsearch=1
  map /  <Plug>(incsearch-forward)
  map n  <Plug>(incsearch-nohl-n)
  map N  <Plug>(incsearch-nohl-N)
  map *  <Plug>(incsearch-nohl-*)
  map #  <Plug>(incsearch-nohl-#)
  map g* <Plug>(incsearch-nohl-g*)
  map g# <Plug>(incsearch-nohl-g#)
  map <LEADER>/ <Plug>(incsearch-forward)<C-r><C-w><CR>


  let g:git_messenger_floating_win_opts = { 'border': 'single' }
  let g:git_messenger_popup_content_margins = v:false
  nmap <LEADER>gm :GitMessenger<CR>
  Plug 'rhysd/git-messenger.vim'


  " colorscheme
  Plug 'dracula/vim', { 'as': 'dracula' }
  " Plug '~/gdrive/code/dracula-pro/themes/vim'
  " let g:dracula_colorterm = 0


  Plug 'tpope/vim-vinegar'
  let g:netrw_liststyle=3
  noremap <LEADER>z :Vexplore<CR>


  Plug 'mattboehm/vim-accordion'
  nnoremap <LEADER>a2 :Accordion 2<CR>
  nnoremap <LEADER>a4 :Accordion 4<CR>
  autocmd VimEnter,VimResized * call s:AutoSetAccordionValue()

  fun! s:AutoSetAccordionValue()
    execute ":AccordionAll " . string(floor(&columns/101))
  endfun

  " function! CocAfterUpdate(info)
  "   CocInstall coc-eslint
  "   CocInstall coc-prettier
  " endfunction
  Plug 'neoclide/coc.nvim', {'branch': 'release'}


  Plug 'cohama/lexima.vim'


  Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}
  Plug 'windwp/nvim-ts-autotag'


  Plug 'neovim/nvim-lspconfig'
  Plug 'tami5/lspsaga.nvim'
  Plug 'JoosepAlviste/nvim-ts-context-commentstring'


  Plug 'nvim-lua/popup.nvim'
  Plug 'nvim-lua/plenary.nvim'
  Plug 'nvim-telescope/telescope.nvim'

  nnoremap <LEADER>ff <cmd>Telescope find_files<CR>
  nnoremap <LEADER>fg <cmd>Telescope live_grep<CR>
  nnoremap <LEADER>fb <cmd>Telescope buffers<CR>
  nnoremap <LEADER>fr <cmd>Telescope lsp_references<CR>
  nnoremap <LEADER>fd <cmd>Telescope lsp_workspace_diagnostics<CR>
  nnoremap <LEADER>gs <cmd>Telescope git_status<CR>
  nnoremap <LEADER>gb <cmd>Telescope git_branches<CR>


  Plug 'hrsh7th/nvim-compe'


  Plug 'TimUntersberger/neogit'


  Plug 'kyazdani42/nvim-web-devicons'
  Plug 'hoob3rt/lualine.nvim'


  Plug 'thaerkh/vim-workspace'
  let g:workspace_autocreate = 1
  let g:workspace_session_disable_on_args = 1
  let g:workspace_autosave = 0
  " This plugin functionality makes no sense, it's completely unrelated from its
  " core functionality :|
  let g:workspace_autosave_untrailspaces = 0
  let g:workspace_autosave_untrailtabs = 0

  let g:workspace_session_directory = expand('~/.local/share/nvim/sessions')
  let g:workspace_undodir = expand('~/.local/share/nvim/sessions/.undodir')


endif


call plug#end()

if !exists('g:vscode')

  " NOTE: Order is important. You can't lazy load lexima.vim.
  let g:lexima_no_default_rules = v:true
  call lexima#set_default_rules()
  inoremap <silent><expr> <CR> compe#confirm(lexima#expand('<LT>CR>', 'i'))

lua <<EOF
  require'init'
EOF

endif

if !exists('g:vscode')

  colorscheme dracula
  " colorscheme dracula_pro

endif


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


"whitespace in the end of the lines
"http://vim.wikia.com/wiki/Highlight_unwanted_spaces
nnoremap <LEADER>W a<ESC><Bar>:%s/\s\+$//<Bar><CR>``:noh<CR>
highlight ExtraWhitespace ctermbg=darkred guibg=darkred
match ExtraWhitespace /\s\+$/
autocmd WinEnter,InsertLeave * match ExtraWhitespace /\s\+$/
autocmd InsertEnter * match ExtraWhitespace /\s\+\%#\@<!$/
autocmd BufWinLeave * call clearmatches()
autocmd ColorScheme * highlight ExtraWhitespace ctermbg=darkred guibg=darkred

" starts terminal mode on insert mode
" disables line numbers on a newly opened terminal window (not really working)
autocmd TermOpen term://* startinsert | setlocal nonumber
" close terminal buffer without showing the exit status of the shell
autocmd TermClose term://* call feedkeys("\<cr>")
" tnoremap <Esc> <C-\><C-n>

fun! SourceIfExists(file)
  if filereadable(expand(a:file))
    exe 'source' a:file
  endif
endfun

call SourceIfExists($HOME . "/.fb-vimrc")

" fun! CompleteMonths(findstart, base)
"   if a:findstart
"     " locate the start of the word
"     let line = getline('.')
"     let start = col('.') - 1
"     while start > 0 && line[start - 1] =~ '\a'
"       let start -= 1
"     endwhile
"     return start
"   else
"     " find months matching with "a:base"
"     let res = []
"     for m in split("Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec")
"       if m =~ '^' . a:base
"   call add(res, m)
"       endif
"     endfor
"     return res
"   endif
" endfun
" set completefunc=CompleteMonths

filetype plugin indent on
