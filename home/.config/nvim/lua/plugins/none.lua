local utils = require('utils')

    -- mason doesn't work on the meta server, so we only use black, stylua
    -- and prettier when not on meta.
function get_sources()
  if utils.is_meta_server() then
    local meta = require("meta")
    if meta.null_ls.diagnostics.arclint.generator.async_iterator then
      return { meta.null_ls.diagnostics.arclint }
    end
    return { require('arclint') }
  end
  local none = require('null-ls')
  return {
    none.builtins.formatting.black,
    none.builtins.formatting.stylua,
    none.builtins.formatting.prettier,
  }
end

return {
  'nvimtools/none-ls.nvim',
  dependencies = { 'nvim-lua/plenary.nvim' },
  config = function()
    local none = require('null-ls')
    none.setup({
      on_attach = utils.auto_format_on_save,
      sources = get_sources(),
    })
  end,
}
