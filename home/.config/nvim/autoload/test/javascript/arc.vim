
function! test#javascript#arc#test_file(file) abort
  return a:file =~# g:test#javascript#jest#file_pattern && filereadable('.arcconfig') && executable('jest')
endfunction

function! test#javascript#arc#build_args(args, color) abort
  return ['--verbose=false'] + a:args
endfunction

function! test#javascript#arc#executable() abort
  return 'jest'
endfunction

function! s:nearest_test(position) abort
  let name = test#base#nearest_test(a:position, g:test#javascript#patterns)
  return (len(name['namespace']) ? '^' : '') .
       \ test#base#escape_regex(join(name['namespace'] + name['test'])) .
       \ (len(name['test']) ? '$' : '')
endfunction

function! test#javascript#arc#build_position(type, position) abort
  if a:type ==# 'nearest'
    let name = s:nearest_test(a:position)
    if !empty(name)
      let name = '-t '.shellescape(name, 1)
    endif
    return [name, a:position['file']]
  elseif a:type ==# 'file'
    return [a:position['file']]
  else
    return []
  endif
endfunction
