return {
  {
    'fabiomcosta/sanfona.nvim',
    dependencies = {
      'christoomey/vim-tmux-navigator',
    },
    config = function()
      local sanfona = require('sanfona')
      sanfona.setup({
        min_width = (tonumber(vim.o.colorcolumn) or 80) + 11,
      })
      vim.keymap.set('n', '<C-k>', sanfona.win_focus_up, {remap = true})
    end,
  },
}
