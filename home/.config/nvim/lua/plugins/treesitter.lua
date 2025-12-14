local utils = require('secrets.meta.utils')

local function setup_proxy()
  if utils.is_meta_server() and utils.proxy then
    require('nvim-treesitter.install').command_extra_args = {
      curl = { '--proxy', utils.proxy },
    }
  end
end

return {
  {
    'nvim-treesitter/nvim-treesitter',
    -- It is dap_repl needs nvim-dap-repl-highlights to be setup before it can
    -- be installed.
    dependencies = { 'LiadOz/nvim-dap-repl-highlights' },
    config = function()
      setup_proxy()
      require('nvim-treesitter.parsers').get_parser_configs().hgcommit = {
        install_info = {
          url = 'https://github.com/fabiomcosta/tree-sitter-hg-commit',
          files = { 'src/parser.c' },
          branch = 'master',
        },
      }
      -- This is needed to make the neotest-testrunner adapter work
      -- neotest uses Plenary's filetype function to define the filetype
      -- of a buffer based on their filename, which works in most cases
      -- but not for hack files.
      vim.treesitter.language.register('hack', 'php')

      -- This drasticaly improves the javascript code highlight especially on
      -- flow and jsx code.
      vim.treesitter.language.register('tsx', 'javascript')

      require('nvim-treesitter.configs').setup({
        sync_install = true,
        parser_install_dir = vim.fs.joinpath(vim.fn.stdpath('data'), 'site'),
        ensure_installed = {
          'javascript',
          'typescript',
          'tsx',
          'lua',
          'html',
          'fish',
          'json',
          'yaml',
          'scss',
          'css',
          'python',
          'bash',
          'erlang',
          'graphql',
          'hack',
          'vim',
          'regex',
          'markdown',
          'markdown_inline',
          'dap_repl',
          'hgcommit',
          'query',
          'vimdoc',
          'kotlin',
        },
        highlight = {
          enable = true,
          disable = { 'c' },
        },
        indent = {
          enable = true,
          disable = { 'c', 'org' },
        },
        autotag = {
          enable = true,
        },
        -- refactor = {
        --   highlight_definitions = { enable = true },
        --   smart_rename = {
        --     enable = true,
        --     keymaps = {
        --       smart_rename = '<LEADER>rn',
        --     },
        --   },
        -- },
      })
    end,
    build = function()
      setup_proxy()
      require('nvim-treesitter.install').update({ with_sync = true })()
    end,
  },
  {
    'nvim-treesitter/nvim-treesitter-refactor',
    dependencies = { 'nvim-treesitter/nvim-treesitter' },
  },
  {
    'windwp/nvim-ts-autotag',
    dependencies = { 'nvim-treesitter/nvim-treesitter' },
  },
  {
    'JoosepAlviste/nvim-ts-context-commentstring',
    dependencies = { 'nvim-treesitter/nvim-treesitter' },
    config = function()
      local config = require('ts_context_commentstring.config').config
      require('ts_context_commentstring').setup({
        enable_autocmd = false,
        languages = {
          hack = config.languages.php,
        },
      })
      local get_option = vim.filetype.get_option
      vim.filetype.get_option = function(filetype, option)
        return option == 'commentstring'
            and require('ts_context_commentstring.internal').calculate_commentstring()
          or get_option(filetype, option)
      end
    end,
  },
}
