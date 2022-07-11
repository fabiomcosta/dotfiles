
augroup Trouble
  autocmd!
  au DiagnosticChanged * lua require'trouble'.refresh({auto = true, provider = "diagnostics"})
  autocmd BufWinEnter,BufEnter * lua require("trouble").action("on_win_enter")
augroup end

function! s:complete(arg,line,pos) abort
  return join(sort(luaeval('vim.tbl_keys(require("trouble.providers").providers)')), "\n")
endfunction

command! -nargs=* -complete=custom,s:complete Trouble lua require'trouble'.open(<f-args>)
command! -nargs=* -complete=custom,s:complete TroubleToggle lua require'trouble'.toggle(<f-args>)
command! TroubleClose lua require'trouble'.close()
command! TroubleRefresh lua require'trouble'.refresh()

