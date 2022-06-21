let g:test#php#arc#test_patterns = {
  \ 'test': [
    \ '\v^\s*public async function (test\w+)\(',
    \ '\v^\s*public function (test\w+)\(',
    \ '\v^\s*\*\s*(\@test)',
    \ '\v^\s*\/\*\*\s*(\@test)\s*\*\/',
  \],
  \ 'namespace': [],
\}

function! test#php#arc#test_file(file) abort
  return test#php#phpunit#test_file(a:file)
endfunction

" From https://github.com/vim-test/vim-test/blob/ee81a7a50c684298b0eb12bcbdef8cfe3eb1f515/autoload/test/php/phpunit.vim#L24-L37
function! test#php#arc#build_position(type, position) abort
  if a:type ==# 'nearest'
    let name = s:nearest_test(a:position)
    if !empty(name)
      let name = '--filter '.shellescape('\b'.name.'\b', 1)
    endif
    return [name, a:position['file']]
  elseif a:type ==# 'file'
    return [a:position['file']]
  else
    return []
  endif
endfunction

function! test#php#arc#build_args(args, color) abort
  return a:args
endfunction

function! test#php#arc#executable() abort
  return 't'
endfunction

function! s:nearest_test(position) abort
  let name = test#base#nearest_test(a:position, g:test#php#arc#test_patterns)
  return join(name['test'])
endfunction
