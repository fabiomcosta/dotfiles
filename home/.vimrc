" options not supported by neovim
if !has("nvim")
  " Use Vim settings, rather then Vi settings (much better!).
  " This must be first, because it changes other options as a side effect.
  set nocompatible

  set ttymouse=xterm
  set ttyfast
endif

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

"Use 24-bit (true-color) mode in Vim/Neovim when outside tmux.
"If you're using tmux version 2.2 or later, you can remove the outermost $TMUX check and use tmux's 24-bit color support
"(see < http://sunaku.github.io/tmux-24bit-color.html#usage > for more information.)
if empty($TMUX)
  if has("nvim")
    "For Neovim 0.1.3 and 0.1.4 < https://github.com/neovim/neovim/pull/2198 >
    let $NVIM_TUI_ENABLE_TRUE_COLOR=1
  endif
  "For Neovim > 0.1.5 and Vim > patch 7.4.1799 < https://github.com/vim/vim/commit/61be73bb0f965a895bfb064ea3e55476ac175162 >
  "Based on Vim patch 7.4.1770 (`guicolors` option) < https://github.com/vim/vim/commit/8a633e3427b47286869aa4b96f2bfc1fe65b25cd >
  " < https://github.com/neovim/neovim/wiki/Following-HEAD#20160511 >
  if has("termguicolors")
    set termguicolors
  endif
endif

" adds possibility of using 256 colors
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
set cursorline
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
" clears search
nnoremap <TAB> %
vnoremap <TAB> %

" dont wrap lines
set wrap
" wrap lines at convenient points
set linebreak
set textwidth=360
set formatoptions=qrn1

" display tabs and trailing spaces
set list
set listchars=tab:▸\ ,eol:¬

" folding options
set foldmethod=indent
set nofoldenable
nnoremap <SPACE> za
vnoremap <SPACE> zf

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

" makes paste work on command-line and search modes
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
nnoremap Q <Nop>

" copies current buffer file path to register
nnoremap cp :let @+=resolve(expand("%"))<CR>

" confirm completion, `<C-g>u` means break undo chain at current position.
inoremap <expr> <CR> pumvisible() ? "\<C-y>" : "\<C-g>u\<CR>"

" so vim won't force pep8 on all python files
let g:python_recommended_style=0

let data_dir = has('nvim') ? stdpath('data') . '/site' : '~/.vim'
if empty(glob(data_dir . '/autoload/plug.vim'))
  silent execute '!curl -fLo '.data_dir.'/autoload/plug.vim --create-dirs  https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

if has("nvim")
  call plug#begin(expand('~/.local/share/nvim/plugged'))
else
  call plug#begin(expand('~/.vim/plugged'))
endif

Plug 'godlygeek/tabular'
Plug 'tomtom/tcomment_vim'
Plug 'jordwalke/VimAutoMakeDirectory'
Plug 'tpope/vim-surround'
Plug 'tpope/vim-repeat'
Plug 'tpope/vim-dispatch'
Plug 'tpope/vim-obsession'
Plug 'jeffkreeftmeijer/vim-numbertoggle'
Plug 'styled-components/vim-styled-components', { 'branch': 'main' }
Plug 'moll/vim-node'
Plug 'jparise/vim-graphql'
Plug 'christoomey/vim-tmux-navigator'
" Plug 'glacambre/firenvim', { 'do': { _ -> firenvim#install(0) } }
" Plug 'w0rp/ale'
" Plug 'junegunn/vim-emoji'


Plug 'alvan/vim-closetag'
let g:closetag_filetypes = 'html,xhtml,phtml,javascript,typescript'


Plug 'tpope/vim-fugitive', {'augroup': 'fugitive'}
Plug 'tpope/vim-rhubarb'
let g:github_enterprise_urls = ['https://github.secureserver.net']


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


Plug 'tpope/vim-vinegar'
let g:netrw_liststyle=3
noremap <LEADER>z :Vexplore<CR>


" colorscheme
Plug 'dracula/vim', { 'as': 'dracula' }
Plug '~/gdrive/code/dracula-pro/themes/vim'
let g:dracula_colorterm = 0
Plug 'gruvbox-community/gruvbox'


if !exists('g:vscode')

  Plug 'mattboehm/vim-accordion'
  nnoremap <LEADER>a2 :Accordion 2<CR>
  nnoremap <LEADER>a4 :Accordion 4<CR>
  autocmd VimEnter,VimResized * call s:AutoSetAccordionValue()

  fun! s:AutoSetAccordionValue()
    execute ":AccordionAll " . string(floor(&columns/101))
  endfun

  " function! CocAfterUpdate(info)
  "   CocInstall coc-actions
  "   CocInstall coc-css
  "   CocInstall coc-eslint
  "   CocInstall coc-flow
  "   CocInstall coc-highlight
  "   CocInstall coc-json
  "   CocInstall coc-marketplace
  "   CocInstall coc-prettier
  "   CocInstall coc-tabnine
  "   CocInstall coc-vimlsp
  "   CocInstall coc-yaml
  " endfunction
  Plug 'neoclide/coc.nvim', {'branch': 'release'}


  " You will have bad experience for diagnostic messages when it's default 4000.
  set updatetime=300
  nmap <silent> gd <Plug>(coc-definition)
  nmap <silent> gy <Plug>(coc-type-definition)
  nmap <silent> gi <Plug>(coc-implementation)
  nmap <silent> gr <Plug>(coc-references)
  " Symbol renaming.
  nmap <leader>rn <Plug>(coc-rename)

  " Use K to show documentation in preview window.
  function! s:show_documentation()
    if (index(['vim','help'], &filetype) >= 0)
      execute 'h '.expand('<cword>')
    else
      call CocAction('doHover')
    endif
  endfunction
  nnoremap <silent> K :call <SID>show_documentation()<CR>

  " Highlight symbol under cursor on CursorHold
  autocmd CursorHold * silent call CocActionAsync('highlight')

  " Add `:Format` command to format current buffer.
  command! -nargs=0 Format :call CocAction('format')

  nnoremap <LEADER>fc :Format<CR>

  " coc-actions
  " Remap for do codeAction of selected region
  function! s:cocActionsOpenFromSelected(type) abort
    execute 'CocCommand actions.open ' . a:type
  endfunction
  xmap <silent> <leader>a :<C-u>execute 'CocCommand actions.open ' . visualmode()<CR>
  nmap <silent> <leader>a :<C-u>set operatorfunc=<SID>cocActionsOpenFromSelected<CR>g@

  " coc-snippets
  " Use <C-l> for trigger snippet expand.
  imap <C-l> <Plug>(coc-snippets-expand)
  " Use <C-j> for select text for visual placeholder of snippet.
  vmap <C-j> <Plug>(coc-snippets-select)
  " Use <C-j> for jump to next placeholder, it's default of coc.nvim
  let g:coc_snippet_next = '<c-j>'
  " Use <C-k> for jump to previous placeholder, it's default of coc.nvim
  let g:coc_snippet_prev = '<c-k>'
  " Use <C-j> for both expand and jump (make expand higher priority.)
  imap <C-j> <Plug>(coc-snippets-expand-jump)


  Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --bin' }
  Plug 'junegunn/fzf.vim'

  nmap <LEADER>p :Files<CR>
  nmap <LEADER>c :Rg<CR>
endif


Plug 'ludovicchabant/vim-gutentags'
let g:gutentags_cache_dir=$HOME . '/.cache/tags'
" improves perf of ctags by only generating tags for the non-ignored VCS files
let g:gutentags_file_list_command={
\ 'markers': {
    \ '.git': 'git ls-files',
    \ '.hg': 'hg files',
    \ },
\ }


Plug 'liuchengxu/vim-which-key'
let g:mapleader = ','
nnoremap <silent> <leader> :<c-u>WhichKey ','<CR>


if has("nvim")
  Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}
endif


call plug#end()


" let g:ale_completion_enabled=1
" let g:ale_set_balloons=1
" let g:ale_set_loclist=0
" let g:ale_set_quickfix=1
" let g:ale_sign_error=emoji#for('poop')
" let g:ale_sign_warning=emoji#for('small_orange_diamond')
" let g:ale_echo_msg_format='[%linter%][%code] %%s'
" nmap gd :ALEGoToDefinition<CR>
" nmap gh :ALEHover<CR>
" nmap <silent> <C-k> <Plug>(ale_previous_wrap)
" nmap <silent> <C-j> <Plug>(ale_next_wrap)
" let g:ale_linters = {
" \ 'javascript': ['eslint'],
" \}


if has("nvim")
lua <<EOF
require'nvim-treesitter.configs'.setup {
  ensure_installed = { "typescript", "tsx" },
  highlight = {
    enable = true
  },
  indent = {
    enable = false
  }
}
local parser_config = require "nvim-treesitter.parsers".get_parser_configs()
parser_config.tsx.used_by = "javascript"
EOF
endif


colorscheme dracula
" colorscheme dracula_pro
" colorscheme gruvbox


" statusline
set laststatus=2
set statusline=%#statusline#%{ChangeStatuslineColor()}%f%=%m%r%y
fun! ChangeStatuslineColor()
  if getbufvar(bufnr('%'),'&mod')
    hi! statusline guifg=#F92672 guibg=#232526 ctermfg=199 ctermbg=16
  else
    hi! statusline guifg=#455354 guibg=fg      ctermfg=238 ctermbg=253
  endif
  return ''
endfun


" from https://github.com/wincent/wincent/blob/master/.vim/plugin/term.vim
" automagicaly enables paste mode when pasting content from iterm
" make use of Xterm "bracketed paste mode"
" http://www.xfree86.org/current/ctlseqs.html#Bracketed%20Paste%20Mode
" http://stackoverflow.com/questions/5585129
if &term =~ 'screen' || &term =~ 'xterm'
  fun! s:BeginXTermPaste(ret)
    set paste
    return a:ret
  endfun

  " enable bracketed paste mode on entering Vim
  let &t_ti .= "\e[?2004h"

  " disable bracketed paste mode on leaving Vim
  let &t_te = "\e[?2004l" . &t_te

  set pastetoggle=<Esc>[201~
  inoremap <expr> <Esc>[200~ <SID>BeginXTermPaste("")
  nnoremap <expr> <Esc>[200~ <SID>BeginXTermPaste("i")
  vnoremap <expr> <Esc>[200~ <SID>BeginXTermPaste("c")
  cnoremap <Esc>[200~ <nop>
  cnoremap <Esc>[201~ <nop>
endif


"indentation stuff
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

nnoremap <LEADER>fi :retab<CR>
nnoremap <LEADER>tit :call ToggleIndentationType()<CR>
nnoremap <LEADER>tis :call ToggleIndentationSize()<CR>
nnoremap <LEADER>di :call NaiveIndentationDetector()<CR>


fun! CodeHubGetLineRange(mode)
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

fun! CodeHubGetURL(mode)
  let BASE_URL = 'https://www.internalfb.com/code/'
  " TODO: maybe we can ge this from the remote URL?
  let repo = 'whatsapp-wajs'
  let git_path_prefix = trim(system('git rev-parse --show-prefix'))
  let line_range = CodeHubGetLineRange(a:mode)
  " echo line_range
  " echo 'mode ' . mode()
  let local_path = resolve(expand("%"))
  let url = BASE_URL . repo . '/' . git_path_prefix . local_path . '?lines=' . line_range
  echo 'copied ' . url
  return url
endfun

fun! CodeHubOpenFile(mode)
  let url = CodeHubGetURL(a:mode)
  execute "silent !open '" . url . "'"
  echo "opening " . url
endfun

nnoremap <LEADER>chg :call CodeHubOpenFile('n')<CR>
vnoremap <LEADER>chg :<C-U>call CodeHubOpenFile('v')<CR>
nnoremap <LEADER>chc :let @+=CodeHubGetURL('n')<CR>
vnoremap <LEADER>chc :<C-U>let @+=CodeHubGetURL('v')<CR>


"whitespace in the end of the lines stuff
"http://vim.wikia.com/wiki/Highlight_unwanted_spaces
nnoremap <LEADER>W a<ESC><Bar>:%s/\s\+$//<Bar><CR>``:noh<CR>
highlight ExtraWhitespace ctermbg=darkred guibg=darkred
match ExtraWhitespace /\s\+$/
autocmd WinEnter,InsertLeave * match ExtraWhitespace /\s\+$/
autocmd InsertEnter * match ExtraWhitespace /\s\+\%#\@<!$/
autocmd BufWinLeave * call clearmatches()
autocmd ColorScheme * highlight ExtraWhitespace ctermbg=darkred guibg=darkred

if has("nvim")
  " starts terminal mode on insert mode
  " disables line numbers on a newly opened terminal window (not really working)
  autocmd TermOpen term://* startinsert | setlocal nonumber
  " close terminal buffer without showing the exit status of the shell
  autocmd TermClose term://* call feedkeys("\<cr>")
  " tnoremap <Esc> <C-\><C-n>
else
  autocmd TerminalOpen * setlocal nonumber
endif

filetype plugin indent on

fun! SourceIfExists(file)
  if filereadable(expand(a:file))
    exe 'source' a:file
  endif
endfun

call SourceIfExists($HOME . "/.fb-vimrc")
