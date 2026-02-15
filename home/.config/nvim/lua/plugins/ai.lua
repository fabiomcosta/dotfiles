return {
  'greggh/claude-code.nvim',
  dependencies = {
    'nvim-lua/plenary.nvim',
  },
  keys = {
    { '<LEADER>ai', '<CMD>ClaudeCode<CR>', desc = 'Toggle Claude Code' },
  },
  opts = {},
}
