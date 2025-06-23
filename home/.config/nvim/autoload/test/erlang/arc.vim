function! test#erlang#arc#test_file(file) abort
  return test#erlang#commontest#test_file(a:file) && filereadable('.arcconfig')
endfunction

function! test#erlang#arc#build_args(args, color) abort
  return ['test'] + a:args
endfunction

function! test#erlang#arc#executable() abort
  return 'buck'
endfunction

let g:test#erlang#arc#test_patterns = {
  \ 'test': [
    \ '\v^(test_\w+)\(',
  \],
  \ 'namespace': [],
\}

function! s:nearest_test(position) abort
  let name = test#base#nearest_test(a:position, g:test#erlang#arc#test_patterns)
  return join(name['test'])
endfunction

function! test#erlang#arc#build_position(type, position) abort
  if a:type ==# 'nearest'
    let name = s:nearest_test(a:position)
    if !empty(name)
      let name = '-- --regex '.shellescape(name.'$', 1)
    endif
    return [s:buck_module_path(a:position), name]
  elseif a:type ==# 'file'
    return [s:buck_module_path(a:position)]
  else
    return []
  endif
endfunction

function! s:basename_without_extension(position) abort
  return fnamemodify(a:position.file, ':t:r')
endfunction

function! s:path_without_last_folder(position) abort
  return fnamemodify(a:position.file, ':h:h')
endfunction

" erl/bizd/test/bizd_business_features_SUITE.erl
" should become
" //erl/bizd:bizd_business_features_SUITE
function! s:buck_module_path(position) abort
    let filename = s:basename_without_extension(a:position)
    let path = s:path_without_last_folder(a:position)
    return '//' . path . ':' . filename
endfunction
