lua <<EOF
  require('init')
EOF

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
  let local_path = resolve(fnamemodify(expand('%'), ':~:.'))
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
