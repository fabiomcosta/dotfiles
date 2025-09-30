-- return {
--   "nvim-neotest/neotest",
--   dependencies = {
--     "nvim-neotest/nvim-nio",
--     "nvim-lua/plenary.nvim",
--     "antoinemadec/FixCursorHold.nvim",
--     "nvim-treesitter/nvim-treesitter",
--     'nvim-neotest/neotest-jest',
--     { dir = "~/neotest-testrunner" }
--   },
--   config = function()
--     require("neotest").setup({
--       log_level = 0,
--       discovery = { enabled = false },
--       watch = {
--         symbol_queries = {
--           hack = [[
--             ;query
--             ;; Catches {@symbol}::*
--             ;; ex: await WhatsAppSMBMarketingMessagesABProps::genABPropByWABA<bool>()
--             ;; @symbol == WhatsAppSMBMarketingMessagesABProps
--             ;; ex: EnumName::ENUM_VALUE
--             ;; @symbol == EnumName
--             ;; ex: global_function()
--             ;; @symbol == global_function
--             (qualified_identifier) @symbol
--           ]]
--         }
--       },
--       summary = {
--         open = "botright split | horizontal resize 40"
--       },
--       adapters = {
--         require("neotest-testrunner").hack
--         -- require('neotest-jest')({
--         --   -- jestCommand = "jest",
--         --   -- jestConfigFile = ".arcconfig",
--         --   -- env = { CI = true },
--         --   -- cwd = function(_)
--         --   --   return vim.fn.getcwd()
--         --   -- end,
--         -- }),
--       },
--     })
--
--     vim.keymap.set('n', '<LEADER>tf', function()
--       require('neotest').run.run(vim.fn.expand('%'))
--     end)
--
--     vim.keymap.set('n', '<LEADER>tn', function()
--       require('neotest').run.run()
--     end)
--
--     vim.keymap.set('n', '<LEADER>tl', function()
--       require('neotest').run.run_last()
--     end)
--
--     vim.keymap.set('n', '<LEADER>tk', function()
--       require('neotest').summary.close()
--     end)
--
--     vim.keymap.set('n', '<LEADER>tw', function()
--       require('neotest').watch.toggle()
--     end)
--
--     vim.keymap.set('n', '<LEADER>to', function()
--       require('neotest').output.open()
--     end)
--   end
-- }
--
local utils = require('utils')
local set_keymap = utils.set_keymap

return {
  'vim-test/vim-test',
  config = function()
    vim.g['test#strategy'] = 'neovim'
    vim.g['test#neovim#term_position'] = 'botright 20'
    vim.g['test#neovim#start_normal'] = 1
    vim.g['test#javascript#jest#options'] = '--verbose=false'
    vim.g['test#custom_runners'] =
      { PHP = { 'Arc' }, JavaScript = { 'Arc' }, Erlang = { 'Arc' } }

    -- Closes the last term window that is also full-width.
    local kill_bottom_sheet = function()
      local max_width = vim.o.columns

      for window_nr = vim.fn.winnr('$'), 0, -1 do
        local window_id = vim.fn.win_getid(window_nr)
        local window_width = vim.fn.winwidth(window_id)
        local window_pos = vim.api.nvim_win_get_position(window_id)

        local is_full_width = window_width == max_width
        local is_top_positioned = window_pos[1] == 0

        if is_full_width and not is_top_positioned then
          local win_info = vim.fn.getwininfo(window_id)[1]
          if win_info.terminal == 1 then
            local window_height = vim.fn.winheight(window_id)
            -- Sticky size/position
            vim.g['test#neovim#term_position'] = 'botright ' .. window_height
          end
          return vim.api.nvim_win_close(window_id, false)
        end
      end
    end

    local create_handler_with_preserved_focus = function(fn)
      return function()
        local current_window_id = vim.api.nvim_get_current_win()
        fn()
        vim.api.nvim_set_current_win(current_window_id)
      end
    end

    vim.keymap.set(
      'n',
      '<LEADER>tk',
      kill_bottom_sheet,
      { desc = 'Kills "bottom sheet" window' }
    )
    vim.keymap.set(
      'n',
      '<LEADER>tn',
      create_handler_with_preserved_focus(function()
        kill_bottom_sheet()
        vim.cmd('TestNearest')
      end),
      {}
    )
    vim.keymap.set(
      'n',
      '<LEADER>tf',
      create_handler_with_preserved_focus(function()
        kill_bottom_sheet()
        vim.cmd('TestFile')
      end),
      {}
    )
    vim.keymap.set(
      'n',
      '<LEADER>ts',
      create_handler_with_preserved_focus(function()
        kill_bottom_sheet()
        vim.cmd('TestSuite')
      end),
      {}
    )
    vim.keymap.set(
      'n',
      '<LEADER>tl',
      create_handler_with_preserved_focus(function()
        kill_bottom_sheet()
        vim.cmd('TestLast')
      end),
      {}
    )
    set_keymap('n', '<LEADER>tg', ':TestVisit<CR>', { noremap = false })
  end,
}
