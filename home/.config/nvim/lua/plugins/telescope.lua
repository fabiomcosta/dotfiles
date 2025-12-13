local utils = require('secrets.meta.utils')

return {
  'nvim-telescope/telescope.nvim',
  dependencies = {
    'nvim-lua/plenary.nvim',
    'nvim-telescope/telescope-fzy-native.nvim',
  },
  config = function()
    local telescope_setup = {}
    if vim.fn.executable('fd') == 1 then
      telescope_setup.pickers = {
        find_files = {
          find_command = {
            'fd',
            '--type',
            'f',
            '--strip-cwd-prefix',
            '--exclude',
            'custom_modules',
            '--exclude',
            'submodules',
            '--exclude',
            'node_modules',
          },
        },
      }
    end
    if vim.fn.executable('rg') == 1 then
      telescope_setup.defaults = {
        vimgrep_arguments = {
          'rg',
          '--color=never',
          '--no-heading',
          '--with-filename',
          '--line-number',
          '--column',
          '--smart-case',
          '--trim',
        },
      }
    end
    require('telescope').setup(telescope_setup)
    require('telescope').load_extension('fzy_native')

    if utils.is_arc_root() then
      if utils.is_myles_repo() then
        vim.keymap.set('n', '<LEADER>ff', '<cmd>Telescope myles<CR>')
      elseif utils.is_biggrep_repo() then
        vim.keymap.set(
          'n',
          '<LEADER>ff',
          '<cmd>Telescope biggrep f exclude=__(tests|generated|db_generated)__<CR>'
        )
      else
        vim.keymap.set('n', '<LEADER>ff', '<cmd>Telescope find_files<CR>')
        vim.keymap.set('n', '<LEADER>fg', '<cmd>Telescope live_grep<CR>')
      end
      if utils.is_biggrep_repo() then
        vim.keymap.set(
          'n',
          '<LEADER>fg',
          '<cmd>Telescope biggrep s exclude=__(tests|generated|db_generated)__<CR>'
        )
      end
    else
      vim.keymap.set('n', '<LEADER>ff', '<cmd>Telescope find_files<CR>')
      vim.keymap.set('n', '<LEADER>fg', '<cmd>Telescope live_grep<CR>')
    end

    vim.keymap.set('n', '<LEADER>fh', '<cmd>Telescope help_tags<CR>')
    vim.keymap.set(
      'n',
      '<LEADER>fj',
      '<cmd>Telescope find_files hidden=true<CR>'
    )
    vim.keymap.set('n', '<LEADER>fb', '<cmd>Telescope buffers<CR>')
    vim.keymap.set('n', '<LEADER>fd', '<cmd>Telescope diagnostics<CR>')
    vim.keymap.set('n', '<LEADER>gs', '<cmd>Telescope git_status<CR>')
  end,
}
