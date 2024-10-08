-- TODO
-- * [done] improve colors to better match web slog
-- * [done] quick filter functionality
-- * [done] use signs when previewing files to highlight the line http://vimdoc.sourceforge.net/htmldoc/sign.html
--   https://stackoverflow.com/questions/2150220/how-do-i-make-vim-syntax-highlight-a-whole-line
-- * [done] hover functionality to show full text
-- * [done] online/offline checks
-- * [done] create paste from current log
-- * [done] when there are filters applied, show number of shown and total logs messages
-- * [done] possibility of showing date using client's timezone (considering TZ's environment variable)
-- * [done] advanced filter functionality/command
-- * allow jumping to definition on some of the special base64json elements
-- PERF
-- * [done] improve perf when jumping to file
-- * improve re-renders with better UI caching
-- * optimize tailer to output buffer when it gets a complete log json entry,
--   instead of waiting for the end of the response to output.

local View = require('slog.view')
local config = require('slog.config')
local colors = require('slog.colors')
local util = require('slog.util')

local Slog = {}

local view

local function is_open()
  return view and view:is_valid()
end

function Slog.open()
  if is_open() then
    view:update()
  else
    view = View.create()
  end
end

function Slog.close()
  if is_open() then
    view:close()
  end
end

function Slog.toggle()
  if is_open() then
    Slog.close()
  else
    Slog.open()
  end
end

function Slog.clear()
  if is_open() then
    view:clear()
  end
end

function Slog.action(action)
  if not is_open() then
    return Slog
  end

  util.debug(action)

  if action == "open_split" then
    view:jump({ precmd = "split" })
  elseif action == "open_vsplit" then
    view:jump({ precmd = "vsplit" })
  elseif action == "open_tab" then
    view:jump({ precmd = "tabe" })
  elseif action == "jump" then
    view:jump()
  elseif action == "jump_close" then
    view:jump()
    Slog.close()
  elseif action == "close" then
    Slog.close()
  elseif action == "cancel" then
    view:switch_to_parent()
  elseif action == "preview" then
    view:preview()
  elseif action == "toggle_filter" then
    view:toggle_filter()
  elseif action == "hover" then
    view:hover()
  elseif action == "paste" then
    view:paste()
  elseif action == "clear" then
    Slog.clear()
  else
    util.error("Action '" .. action .. "' doesn't exist.")
  end

  return Slog
end

function Slog.setup(opts)
  config.setup(opts)
  colors.setup()

  vim.api.nvim_create_user_command(
    'SlogOpen',
    Slog.open,
    {}
  )
  vim.api.nvim_create_user_command(
    'SlogClose',
    Slog.close,
    {}
  )
  vim.api.nvim_create_user_command(
    'SlogToggle',
    Slog.toggle,
    {}
  )
  vim.api.nvim_create_user_command(
    'SlogClear',
    Slog.clear,
    {}
  )

  vim.api.nvim_create_autocmd('VimEnter', {
    once = true,
    callback = function()
      view = View.attempt_attach()
    end,
  })

  return Slog
end

return Slog
