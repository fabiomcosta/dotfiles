function! test#php#arc#test_file(file) abort
  return test#php#phpunit#test_file(a:file)
endfunction

function! test#php#arc#build_position(type, position) abort
  return test#php#phpunit#build_position(a:type, a:position)
endfunction

function! test#php#arc#build_args(args, color) abort
  return a:args
endfunction

function! test#php#arc#executable() abort
  return 't'
endfunction
