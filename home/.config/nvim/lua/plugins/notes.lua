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
  keys = {
    {
      '<LEADER>nn',
      '<CMD>Obsidian new<CR>',
      desc = 'Create new note',
    },
    {
      '<LEADER>nf',
      '<CMD>Obsidian quick_switch<CR>',
      desc = 'Find note by path',
    },
    {
      '<LEADER>ng',
      '<CMD>Obsidian search<CR>',
      desc = 'Find note by content',
    },
  },
}
