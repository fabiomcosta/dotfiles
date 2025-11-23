local utils = require('secrets.meta.utils')
local auto_format_on_save = require('utils').auto_format_on_save

-- mason doesn't work on the meta server, so we only use black, stylua
-- and prettier when not on meta.
local function get_sources()
  if utils.is_meta_server() then
    local meta = require('meta')
    return { meta.null_ls.diagnostics.arclint }
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
  dependencies = { 'meta.nvim', 'nvim-lua/plenary.nvim' },
  config = function()
    local none = require('null-ls')
    none.setup({
      on_attach = auto_format_on_save,
      sources = get_sources(),
    })
  end,
}
