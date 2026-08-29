return {
  'obsidian-nvim/obsidian.nvim',
  dependencies = {
    {
      'OXY2DEV/markview.nvim',
      lazy = false,
    },
    { 'antonk52/markdowny.nvim' },
  },
  version = '*', -- use latest release, remove to use latest commit
  ft = 'markdown',
  opts = {
    legacy_commands = false, -- this will be removed in the next major release
    link = {
      style = 'markdown', -- "wiki" (default) or "markdown"
    },
    checkbox = {
      order = { ' ', 'x' },
    },
    workspaces = {
      {
        name = 'personal',
        path = '~/Notes/personal',
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
    -- Depends on markdowny
    {
      '<LEADER>nk',
      function()
        require('markdowny').link()
      end,
      mode = 'v',
      desc = 'Create link',
    },
  },
}
