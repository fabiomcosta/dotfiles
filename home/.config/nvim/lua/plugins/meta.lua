local is_meta_server = require('utils').is_meta_server

return {
  dir = '/usr/share/fb-editor-support/nvim',
  name = 'meta.nvim',
  dependencies = {
    'nvimtools/none-ls.nvim',
    'neovim/nvim-lspconfig',
    'nvim-treesitter/nvim-treesitter',
    'nvim-lua/plenary.nvim',
  },
  enabled = is_meta_server(),
  config = function()
    require('meta')
  end,
}
