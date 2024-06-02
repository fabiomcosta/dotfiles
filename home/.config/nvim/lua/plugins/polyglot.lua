return {
  -- This plugin already constains 'tpope/vim-sleuth'
  'sheerun/vim-polyglot',
  init = function()
    vim.g.polyglot_disabled = { 'ftdetect', 'sensible' }
  end,
  config = function()
    vim.g.javascript_plugin_flow = 1
  end,
}
