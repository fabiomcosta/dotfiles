return {
  'obsidian-nvim/obsidian.nvim',
  dependencies = {
    'OXY2DEV/markview.nvim',
    lazy = false,
  },
  version = '*', -- use latest release, remove to use latest commit
  ft = 'markdown',
  opts = {
    legacy_commands = false, -- this will be removed in the next major release
    checkbox = {
      order = { ' ', 'x' },
    },
    workspaces = {
      {
        name = 'personal',
        path = '~/notes/personal',
      },
    },
  },
}
