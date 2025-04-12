local utils = require('utils')
local set_keymap = utils.set_keymap
local is_meta_server = utils.is_meta_server

return {
  dir = '/usr/share/fb-editor-support/nvim',
  -- dir = '~/fbsource/fbcode/editor_support/nvim',
  name = 'meta.nvim',
  dependencies = {
    'nvimtools/none-ls.nvim',
    'neovim/nvim-lspconfig',
    'nvim-treesitter/nvim-treesitter',
    'nvim-lua/plenary.nvim',
    'mfussenegger/nvim-dap',
  },
  enabled = is_meta_server(),
  config = function()
    require('meta').setup()

    -- These are known core modules that ppl would likely want to keep hidden
    -- to avoid having them polute the trace while debugging.
    local TRACE_FILTER_RULES = {
      exact = {
        ['www/unknown'] = 1,
        ['flib/init/zeusgodofthunder/__entrypoint.php'] = 1,
        ['flib/init/routing/ZeusGodOfThunderAlite.php'] = 1,
        ['flib/core/runtime/error/debug_rlog.php'] = 1,
        ['flib/core/logger/logger.php'] = 1,
        ['flib/core/shutdown/PSP.php'] = 1,
      },
      startswith = {
        'flib/purpose/cipp/',
        'flib/profiling/',
        'flib/core/asio/'
      },
    }

    local _, slog = pcall(require, 'meta.slog')
    slog = slog or require('slog')

    local _0, slog_util = pcall(require, 'meta.slog.util')
    slog_util = slog_util or require('slog.util')

    slog.setup({
      filters = {
        log = function(log)
          local level = log.attributes.level
          if level == 'mustfix' or level == 'fatal' or level == 'slog' then
            return true
          end
          return false
        end,
        trace = function(trace)
          if trace.fileName ~= null then
            local filename = slog_util.get_relative_filename(trace.fileName)
            if TRACE_FILTER_RULES.exact[filename] ~= nil then
              return false
            end
            if vim.tbl_contains(TRACE_FILTER_RULES.startswith, function (prefix)
              return vim.startswith(filename, prefix)
            end, { predicate = true }) then
              return false
            end
          end
          return true
        end
      }
    })

    set_keymap('n', '<LEADER>st', '<CMD>SlogToggle<CR>')
  end,
}
