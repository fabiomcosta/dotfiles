return {
  'mattboehm/vim-accordion',
  config = function()
    -- This makes sure that accordion won't change the height of horizontal
    -- windows/buffers when it calls "wincmd =", and the same for us.
    vim.cmd([[autocmd WinNew * set winfixheight]])
    -- TODO when autocmd is supported on lua we can try to move this to lua properly
    vim.api.nvim_create_user_command('AccordionAutoResize', function()
      vim.cmd(
        [[execute ":AccordionAll " . string(floor(&columns/(&colorcolumn + 11)))]]
      )
    end, {})
    vim.cmd([[autocmd VimEnter,VimResized * :AccordionAutoResize]])
  end,
}
