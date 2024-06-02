return {
  'hoob3rt/lualine.nvim',
  dependencies = {
    { 'dracula/vim', name = 'dracula' },
    'kyazdani42/nvim-web-devicons',
  },
  config = function()
    require('lualine').setup({
      options = {
        theme = 'dracula',
      },
      sections = {
        lualine_a = { 'branch' },
        lualine_b = {},
        lualine_c = { { 'filename', path = 1 } },
        lualine_x = { 'diagnostics' },
        lualine_y = { 'filetype' },
      },
      inactive_sections = {
        lualine_c = { { 'filename', path = 1 } },
        lualine_x = {},
      },
    })
  end,
}
