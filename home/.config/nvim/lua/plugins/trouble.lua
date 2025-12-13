return {
  'folke/trouble.nvim',
  dependencies = { 'kyazdani42/nvim-web-devicons' },
  config = function()
    require('trouble').setup({
      height = 20,
      padding = false,
      auto_preview = false,
      auto_close = true,
    })

    vim.keymap.set('n', '<LEADER>xw', '<CMD>Trouble diagnostics toggle<CR>')
    vim.keymap.set(
      'n',
      '<LEADER>xd',
      '<CMD>Trouble diagnostics toggle filter.buf=0<CR>'
    )
  end,
}
