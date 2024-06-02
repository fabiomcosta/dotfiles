local set_keymap = require('utils').set_keymap

return {
  'tpope/vim-projectionist',
  config = function()
    set_keymap('n', '<LEADER>a', ':A<CR>')
    local jest_alternate = {
      ['**/__tests__/*.test.js'] = {
        alternate = '{}.js',
        type = 'test',
      },
      ['*.js'] = {
        alternate = '{dirname}/__tests__/{basename}.test.js',
        type = 'source',
      },
    }
    vim.g.projectionist_heuristics = {
      ['jest.config.js|jest.config.ts'] = jest_alternate,
      ['.arcconfig'] = vim.tbl_deep_extend('keep', {
        ['**/__tests__/*Test.php'] = {
          alternate = '{}.php',
          type = 'test',
        },
        ['*.php'] = {
          alternate = '{dirname}/__tests__/{basename}Test.php',
          type = 'source',
        },
      }, jest_alternate),
    }
  end,
}
