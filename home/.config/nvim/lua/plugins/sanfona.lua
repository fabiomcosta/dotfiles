return {
  {
    'fabiomcosta/sanfona.nvim',
    config = function()
      require('sanfona').setup({
        min_width = vim.o.colorcolumn + 11,
      })
    end,
  },
}
