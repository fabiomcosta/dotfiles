local is_meta_server = require('utils').is_meta_server

return {
  'jackMort/ChatGPT.nvim',
  event = 'VeryLazy',
  dependencies = {
    'MunifTanjim/nui.nvim',
    'nvim-lua/plenary.nvim',
    'folke/trouble.nvim',
    'nvim-telescope/telescope.nvim',
  },
  config = true,
  enabled = not is_meta_server(),
}
