local set_keymap = require('utils').set_keymap

return {
  'folke/trouble.nvim',
  dependencies = { 'kyazdani42/nvim-web-devicons' },
  config = function()
    require('trouble').setup({
      height = 20,
      padding = false,
      auto_preview = false,
      auto_close = true,
    })

    set_keymap('n', '<LEADER>xw', '<CMD>Trouble diagnostics toggle<CR>')
    set_keymap('n', '<LEADER>xd', '<CMD>Trouble diagnostics toggle filter.buf=0<CR>')
  end,
}
