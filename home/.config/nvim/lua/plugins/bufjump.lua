return {
  'kwkarlwang/bufjump.nvim',
  config = function()
    require('bufjump').setup({
      backward_key = '<C-b>',
      forward_key = '<C-n>',
    })
  end,
}
