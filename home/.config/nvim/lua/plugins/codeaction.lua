return {
  'rachartier/tiny-code-action.nvim',
  dependencies = {
    { "folke/snacks.nvim", opts = { terminal = {} } }
  },
  event = 'LspAttach',
  opts = {
    picker = "snacks",
  },
}
