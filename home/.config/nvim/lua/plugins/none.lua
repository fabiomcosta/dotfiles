local utils = require('utils')

return {
  'nvimtools/none-ls.nvim',
  dependencies = { 'nvim-lua/plenary.nvim' },
  config = function()
    local none = require('null-ls')

    -- mason doesn't work on the meta server, so we only use black, stylua
    -- and prettier when not on meta.
    local sources = utils.is_meta_server() and {
      require('arclint'),
    } or {
      none.builtins.formatting.black,
      none.builtins.formatting.stylua,
      none.builtins.formatting.prettier,
    }

    none.setup({
      on_attach = utils.auto_format_on_save,
      sources = sources,
    })
  end,
}
