local utils = require('utils')

return {
  'nvimtools/none-ls.nvim',
  dependencies = { 'nvim-lua/plenary.nvim' },
  enabled = not utils.is_meta_server(),
  config = function()
    local none = require('null-ls')
    none.setup({
      on_attach = utils.auto_format_on_save,
      sources = {
        none.builtins.formatting.black,
        none.builtins.formatting.stylua,
        none.builtins.formatting.prettier,
      },
    })
  end,
}
