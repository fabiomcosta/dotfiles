return {
  'epwalsh/obsidian.nvim',
  version = '*', -- recommended, use latest release instead of latest commit
  dependencies = {
    'nvim-treesitter',
    'hrsh7th/nvim-cmp',
    'nvim-telescope/telescope.nvim',
    'nvim-lua/plenary.nvim',
  },
  opts = {
    workspaces = {
      {
        name = 'main',
        path = '~/notes/main',
      },
    },
  },
}
