function! test#javascript#arc#test_file(file) abort
  return a:file =~# g:test#javascript#jest#file_pattern
endfunction

function! test#javascript#arc#build_position(type, position) abort
  " return test#javascript#jest#build_position(a:type, a:position)
  return [a:position['file']]
endfunction

function! test#javascript#arc#build_args(args, color) abort
  return a:args
endfunction

function! test#javascript#arc#executable() abort
  return 'jest'
endfunction
