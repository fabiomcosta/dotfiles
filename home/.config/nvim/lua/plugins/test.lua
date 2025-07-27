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
      local max_height = vim.o.lines - 1 - vim.o.cmdheight

      for window_nr = vim.fn.winnr('$'), 0, -1 do
        local window_width = vim.fn.winwidth(window_nr)
        local window_height = vim.fn.winheight(window_nr)

        local is_full_width = window_width == max_width
        local is_partial_height = window_height < max_height

        if is_full_width and is_partial_height then
          local window_id = vim.fn.win_getid(window_nr)
          local win_info = vim.fn.getwininfo(window_id)[1]
          if win_info.terminal == 1 then
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
