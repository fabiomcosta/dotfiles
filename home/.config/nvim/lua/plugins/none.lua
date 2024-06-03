local utils = require('utils')

return {
  'nvimtools/none-ls.nvim',
  dependencies = { 'nvim-lua/plenary.nvim' },
  config = function()
    -- none-ls needs to be enabled because "meta" uses it, but we only want to
    -- call setup localy, because mason only works localy.
    if utils.is_meta_server() then
      return
    end

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
