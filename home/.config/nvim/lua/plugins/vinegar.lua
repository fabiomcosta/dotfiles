return {
  'tpope/vim-vinegar',
  config = function()
    vim.g.netrw_liststyle = 3
    vim.keymap.set('n', '<LEADER>z', ':Vexplore<CR>')
  end,
}
