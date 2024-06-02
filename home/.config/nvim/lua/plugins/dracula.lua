return {
  'dracula/vim',
  name = 'dracula',
  lazy = false,
  priority = 1000, -- loads this before all the other start plugins
  config = function()
    vim.cmd([[colorscheme dracula]])
  end,
}
