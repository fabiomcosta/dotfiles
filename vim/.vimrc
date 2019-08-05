
"options not supported by neovim
if !has("nvim")
  "Use Vim settings, rather then Vi settings (much better!).
  "This must be first, because it changes other options as a side effect.
  set nocompatible

  set ttymouse=xterm
  set ttyfast
endif

let mapleader=","

"fonts and other gui stuff
"make sure to install the powerline patched font
"version of the font you like
"https://github.com/Lokaltog/powerline-fonts
if has("gui_running")
  set guioptions-=T "remove toolbar
  set guioptions-=r "remove right-hand scroll bar
  set guioptions-=L "remove left-hand scroll bar
  set cursorline "cursorline is quite expensive when not on a gui

  "activates ligatures when supported
  set macligatures

  try
    set guifont=Fira\ Code:h12
  catch
  endtry
else
  set lazyredraw
endif


"default indent settings
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
set ruler
"allows colors on long lines
set synmaxcol=5000
"allow backspacing over everything in insert mode
set backspace=indent,eol,start
"font line-height
set linespace=0
"adds line numbers to the left
set number
"prevents delay while pressing esc on insert mode
set timeoutlen=1000 ttimeoutlen=0
"uses OS clipboard if possible (check +clipboard)
set clipboard=unnamed
"store lots of :cmdline history
set history=1000
"mark the ideal max text width
set colorcolumn=80
" set termguicolors
"adds possibility of using 256 colors
set t_Co=256

"some stuff to get the mouse going in term
set mouse=a

"keep going up dirs until a tags file is found
set tags=tags;/

"enable ctrl-n and ctrl-p to scroll thru matches
set wildmenu
"make cmdline tab completion similar to bash
set wildmode=list:longest
"ignored files while search files and stuff
set wildignore+=*.so,*.dll,*.exe,*.zip,*.tar,*.gz,*.swf
set wildignore+=*.swp,*.swo,*~,*.pyc
set wildignore+=*.psd,*.png,*.gif,*.jpeg,*.jpg,*.pdf
set wildignore+=*/.git/*,*/.hq/*,*/.svn/*,*/tmp/*
set wildignore+=*/.sass-cache/*
set wildignore+=*.i,*.d,*.sql3 "other exotic extensions

"ignores case
set ignorecase
"do not ignore case if explicitly defined on the search
"by search for an uppercased pattern
set smartcase
"defaults to search for every match of the pattern
set gdefault
set showmatch
"clears search
nnoremap <TAB> %
vnoremap <TAB> %

"dont wrap lines
set wrap
"wrap lines at convenient points
set linebreak
set textwidth=360
set formatoptions=qrn1

"display tabs and trailing spaces
set list
set listchars=tab:▸\ ,eol:¬

"folding options
set foldmethod=indent
set nofoldenable
nnoremap <SPACE> za
vnoremap <SPACE> zf

"turn on syntax highlighting
syntax on

nnoremap j gj
nnoremap k gk
" Use control+up/down to move fast
nnoremap <C-j> 12j
nnoremap <C-k> 12k
vnoremap <C-j> 12j
vnoremap <C-k> 12k

inoremap jj <ESC>
nnoremap ; :

"makes paste work on command-line mode
cnoremap <C-v> <C-r>"

nnoremap <LEADER>ev <C-w><C-v><C-l>:e $MYVIMRC<CR>
nnoremap <LEADER>sv :so $MYVIMRC<CR>
nnoremap <LEADER>w :vsplit<CR><C-w>l
nnoremap <LEADER>v :split<CR><C-w>j

"moves the cursor around the buffer windows
nnoremap <C-h> <C-w>h
nnoremap <C-l> <C-w>l
"nnoremap <C-j> <C-w>j
"nnoremap <C-k> <C-w>k

"changes the size of the buffer windows
nnoremap = <C-w>=
nnoremap + :vertical resize +5<CR>
nnoremap - :vertical resize -5<CR>

cmap w!! w !sudo tee % >/dev/null

vnoremap <LEADER>j :!python -m json.tool<CR>

"underline to camelcase
vnoremap <LEADER>ltc :s#\%V_\(\l\)#\u\1#<CR>:noh<CR>
vnoremap <LEADER>utc :s#\%V_*\(\u\)\(\u*\)#\1\L\2#<CR>:noh<CR>
"camelcase to underline
vnoremap <LEADER>tus :s#\%V\([a-z0-9]\+\)\(\u\)#\l\1_\l\2#g<CR>:noh<CR>

"tab related mappings
nnoremap <LEADER>nt :tabnew<CR>
nnoremap <LEADER>[ :tabprevious<CR>
nnoremap <LEADER>] :tabnext<CR>

"copies current buffer file path to register
nnoremap cp :let @+=resolve(expand("%"))<CR>

"so vim won't force pep8 on all python files
let g:python_recommended_style=0


call plug#begin(expand('~/.vim/plugged'))

" Plug 'SirVer/ultisnips'
" Plug 'honza/vim-snippets'
Plug 'tpope/vim-fugitive', {'augroup': 'fugitive'}
Plug 'christoomey/vim-conflicted'
Plug 'Lokaltog/vim-easymotion'
Plug 'godlygeek/tabular'
Plug 'jszakmeister/vim-togglecursor'
Plug 'tomtom/tcomment_vim'
Plug 'jordwalke/VimAutoMakeDirectory'
Plug 'junegunn/vim-emoji'
Plug 'w0rp/ale'


" Plug 'Galooshi/vim-import-js'
" nnoremap <LEADER>iw :ImportJSWord<CR>
" nnoremap <LEADER>ig :ImportJSGoto<CR>
" nnoremap <LEADER>if :ImportJSFix<CR>


Plug 'mhinz/vim-grepper'
let g:grepper={}
let g:grepper.dir='repo,cwd,file'
let g:grepper.tools=['rg', 'ag', 'git', 'ack', 'grep']
nnoremap <LEADER>g :Grepper -query<SPACE>
nnoremap K :Grepper -query "\b<C-R><C-W>\b"<CR>:cw<CR>
vnoremap K y:Grepper -query "\b<C-R>"\b"<CR>


Plug 'yssl/QFEnter'
let g:qfenter_keymap={}
let g:qfenter_keymap.vopen=['<C-v>']
let g:qfenter_keymap.hopen=['<C-CR>', '<C-s>', '<C-x>']
let g:qfenter_keymap.topen=['<C-t>']


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


Plug 'scrooloose/nerdtree', {'augroup': 'NERDTreeHijackNetrw'}
noremap <LEADER>z :NERDTreeToggle<CR>


Plug 'mattn/emmet-vim'
" You need to enter <C-Z>,
let g:user_emmet_leader_key='<C-Z>'
let g:user_emmet_settings = {
 \ 'javascript.jsx' : {
    \ 'extends' : 'jsx',
    \ },
 \ }


Plug 'tpope/vim-surround'
Plug 'tpope/vim-repeat'


"colorscheme
Plug 'dracula/vim'


Plug 'mattboehm/vim-accordion'
nnoremap <LEADER>a2 :Accordion 2<CR>
nnoremap <LEADER>a4 :Accordion 4<CR>
autocmd VimEnter,VimResized * call s:AutoSetAccordionValue()

fun! s:AutoSetAccordionValue()
  exe ":AccordionAll " . string(floor(&columns/81))
endfun


Plug 'moll/vim-node'
" Plug 'sbdchd/neoformat'
" let g:neoformat_javascript_prettier={
"   \ 'exe': 'prettier',
"   \ 'args': ['--single-quote']
" \ }
" let g:neoformat_enabled_javascript = ['prettier']
" nnoremap <LEADER>fc :Neoformat<CR>


Plug 'neoclide/coc.nvim', {'branch': 'release'}
" Better display for messages
set cmdheight=2
" You will have bad experience for diagnostic messages when it's default 4000.
set updatetime=300
" Use tab for trigger completion with characters ahead and navigate.
" Use command ':verbose imap <tab>' to make sure tab is not mapped by other plugin.
inoremap <silent><expr> <TAB>
      \ pumvisible() ? "\<C-n>" :
      \ <SID>check_back_space() ? "\<TAB>" :
      \ coc#refresh()
inoremap <expr><S-TAB> pumvisible() ? "\<C-p>" : "\<C-h>"
function! s:check_back_space() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~# '\s'
endfunction
" Use <c-space> to trigger completion.
inoremap <silent><expr> <c-space> coc#refresh()
" Use <cr> to confirm completion, `<C-g>u` means break undo chain at current position.
" Coc only does snippet and additional edit on confirm.
inoremap <expr> <cr> pumvisible() ? "\<C-y>" : "\<C-g>u\<CR>"

" Remap keys for gotos
nmap <silent> gd <Plug>(coc-definition)
nmap <silent> gy <Plug>(coc-type-definition)
nmap <silent> gi <Plug>(coc-implementation)
nmap <silent> gr <Plug>(coc-references)
" Use K to show documentation in preview window
nnoremap <silent> K :call <SID>show_documentation()<CR>


Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --bin' }
Plug 'junegunn/fzf.vim'

" Adds Rg command to search on file paths
command! -bang -nargs=* Rgf
  \ call fzf#run({'source': 'rg --column --line-number --no-heading --color=always --smart-case -l .', 'sink': 'e', 'down': '~20%', 'options': ['--ansi', '--prompt', 'ripgrep> ', '--color', 'hl:4,hl+:12']})
" Adds Rg command to search on file content
command! -bang -nargs=* Rgc
  \ call fzf#vim#grep("rg --column --line-number --no-heading --color=always --smart-case ".shellescape(<q-args>), 1, {'options': '--delimiter : --nth 4..'}, <bang>0)
nmap <LEADER>p :Rgf<CR>
nmap <LEADER>c :Rgc<CR>

let g:fzf_layout = { 'down': '~20%' }
" Customize fzf colors to match your color scheme
let g:fzf_colors =
\ { 'fg':      ['fg', 'Normal'],
  \ 'bg':      ['bg', 'Normal'],
  \ 'hl':      ['fg', 'Comment'],
  \ 'fg+':     ['fg', 'CursorLine', 'CursorColumn', 'Normal'],
  \ 'bg+':     ['bg', 'CursorLine', 'CursorColumn'],
  \ 'hl+':     ['fg', 'Statement'],
  \ 'info':    ['fg', 'PreProc'],
  \ 'border':  ['fg', 'Ignore'],
  \ 'prompt':  ['fg', 'Conditional'],
  \ 'pointer': ['fg', 'Exception'],
  \ 'marker':  ['fg', 'Keyword'],
  \ 'spinner': ['fg', 'Label'],
  \ 'header':  ['fg', 'Comment'] }


Plug 'kristijanhusak/vim-js-file-import', {'do': 'npm install'}


call plug#end()


let g:ale_sign_error=emoji#for('poop')
let g:ale_sign_warning=emoji#for('small_orange_diamond')
let g:ale_lint_on_text_changed='never'
let g:ale_lint_on_enter=0
let g:ale_linters = {
\ 'javascript': ['eslint', 'flow'],
\}
" let g:ale_fixers = {
" \ 'javascript': ['eslint'],
" \}


colorscheme dracula


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


"whitespace in the end of the lines stuff
"http://vim.wikia.com/wiki/Highlight_unwanted_spaces
nnoremap <LEADER>W a<ESC><Bar>:%s/\s\+$//<Bar><CR>``:noh<CR>
highlight ExtraWhitespace ctermbg=darkred guibg=darkred
match ExtraWhitespace /\s\+$/
autocmd WinEnter,InsertLeave * match ExtraWhitespace /\s\+$/
autocmd InsertEnter * match ExtraWhitespace /\s\+\%#\@<!$/
autocmd BufWinLeave * call clearmatches()
autocmd ColorScheme * highlight ExtraWhitespace ctermbg=darkred guibg=darkred


filetype plugin indent on
