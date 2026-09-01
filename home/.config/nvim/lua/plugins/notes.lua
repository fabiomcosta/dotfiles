return {
  {
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
      {
        '<LEADER>nki',
        '<CMD>Obsidian link_new<CR>',
        mode = 'v',
        desc = 'Create new internal link to a new md file',
      },
      {
        '<LEADER>nke',
        function()
          require('markdowny').link()
        end,
        mode = 'v',
        desc = 'Create new external link',
      },
    },
  },
  {
    'gaoDean/autolist.nvim',
    ft = { 'markdown', 'text', 'tex', 'plaintex', 'norg' },
    config = function()
      require('autolist').setup()
    end,
    keys = {
      -- {
      --   '<tab>',
      --   '<CMD>AutolistTab<CR>',
      --   mode = 'i',
      --   desc = 'Indent list item',
      -- },
      -- {
      --   '<s-tab>',
      --   '<CMD>AutolistShiftTab<CR>',
      --   mode = 'i',
      --   desc = 'Dedent list item',
      -- },
      {
        '<CR>',
        '<CR><CMD>AutolistNewBullet<CR>',
        mode = 'i',
        desc = 'Continue list with new bullet',
      },
      {
        '<CR>',
        '<CMD>AutolistToggleCheckbox<CR><CR>',
        mode = 'n',
        desc = 'Toggle checkbox',
      },
      {
        'o',
        'o<CMD>AutolistNewBullet<CR>',
        mode = 'n',
        desc = 'New list item below',
      },
      {
        'O',
        'O<CMD>AutolistNewBulletBefore<CR>',
        mode = 'n',
        desc = 'New list item above',
      },
      -- {
      --   '<C-r>',
      --   '<CMD>AutolistRecalculate<CR>',
      --   mode = 'n',
      --   desc = 'Recalculate list',
      -- },
      -- cycle list types with dot-repeat
      {
        '<LEADER>nlc',
        function()
          return require('autolist').cycle_next_dr()
        end,
        expr = true,
        desc = 'Cycle list type (next)',
      },
      -- {
      --   '<LEADER>cp',
      --   function()
      --     return require('autolist').cycle_prev_dr()
      --   end,
      --   expr = true,
      --   desc = 'Cycle list type (previous)',
      -- },
      -- recalculate list on edit
      {
        '>>',
        '>><CMD>AutolistRecalculate<CR>',
        mode = 'n',
        desc = 'Indent and recalculate list',
      },
      {
        '<<',
        '<<<CMD>AutolistRecalculate<CR>',
        mode = 'n',
        desc = 'Dedent and recalculate list',
      },
      {
        'dd',
        'dd<CMD>AutolistRecalculate<CR>',
        mode = 'n',
        desc = 'Delete line and recalculate list',
      },
      {
        'd',
        'd<CMD>AutolistRecalculate<CR>',
        mode = 'v',
        desc = 'Delete and recalculate list',
      },
    },
  },
}
