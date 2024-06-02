local set_keymap = require('utils').set_keymap

return {
  'tpope/vim-vinegar',
  config = function()
    vim.g.netrw_liststyle = 3
    set_keymap('n', '<LEADER>z', ':Vexplore<CR>')
  end,
}
