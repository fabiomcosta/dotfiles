return {
  {
    'mattboehm/vim-accordion',
    config = function()
      -- This makes sure that accordion won't change the height of horizontal
      -- windows/buffers when it calls "wincmd =", and the same for us.
      vim.cmd([[autocmd WinNew * set winfixheight]])

      -- This is actually causing a bug when opening the Telescope windows
      -- and I can't figure out why, simply stopping to run this for now.

      -- vim.api.nvim_create_autocmd({ 'VimEnter', 'VimResized' }, {
      --   pattern = '*',
      --   callback = function()
      --     vim.cmd(
      --       [[execute ":AccordionAll " . string(floor(&columns/(&colorcolumn + 11)))]]
      --     )
      --   end,
      -- })
    end,
  },
}
