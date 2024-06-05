local utils = require('utils')
local set_keymap = utils.set_keymap

return {
  'vim-test/vim-test',
  config = function()
    vim.g['test#strategy'] = 'neovim'
    vim.g['test#neovim#term_position'] = 'botright 20'
    vim.g['test#neovim#start_normal'] = 1
    vim.g['test#javascript#jest#options'] = '--verbose=false'
    vim.g['test#custom_runners'] = { PHP = { 'Arc' }, JavaScript = { 'Arc' } }

    -- Closes the last term window according to vim's order, so either the
    -- bottom-most or if there is none on the bottom, the last to the right.
    vim.keymap.set('n', '<LEADER>tk', function()
      local max_width = vim.o.columns
      local max_height = vim.o.lines - 1 - vim.o.cmdheight

      for window_nr = vim.fn.winnr('$'), 0, -1 do
        local window_nr = i
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
          return utils.replace_termcodes('<C-w>' .. window_nr .. 'c')
        end
      end
      return ''
    end, { expr = true })

    set_keymap(
      'n',
      '<LEADER>tn',
      '<LEADER>tk:TestNearest<CR><C-w>p',
      { noremap = false }
    )
    set_keymap(
      'n',
      '<LEADER>tf',
      '<LEADER>tk:TestFile<CR><C-w>p',
      { noremap = false }
    )
    set_keymap(
      'n',
      '<LEADER>ts',
      '<LEADER>tk:TestSuite<CR><C-w>p',
      { noremap = false }
    )
    set_keymap(
      'n',
      '<LEADER>tl',
      '<LEADER>tk:TestLast<CR><C-w>p',
      { noremap = false }
    )
    set_keymap('n', '<LEADER>tg', ':TestVisit<CR>', { noremap = false })
  end,
}
