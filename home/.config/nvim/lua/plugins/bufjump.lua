local set_keymap = require('utils').set_keymap

return {
  'kwkarlwang/bufjump.nvim',
  config = function()
    require('bufjump').setup({
      backward = '<C-b>',
      forward = '<C-n>',
    })
    set_keymap('n', '<C-p>', '<C-w>p')
  end,
}
