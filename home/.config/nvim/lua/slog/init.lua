-- TODO
-- * [done] replace all Trouble references with Slog
-- * [done] improve colors to better match web slog
-- * [done] quick filter functionality
-- * [done] use signs when previewing files to highlight the line http://vimdoc.sourceforge.net/htmldoc/sign.html
--   https://stackoverflow.com/questions/2150220/how-do-i-make-vim-syntax-highlight-a-whole-line
-- * [done] fix open vsplit, tab etc on jump
-- * filter functionality/command
-- * when there are filters applied, show number of hidden messages (maybe on buffer title)
-- * online/offline checks? (might need the tailer to signal that)
-- * inform if process stops working
-- * allow jumping to definition on some of the special base64json elements
-- PERF
-- * improve re-renders with better UI caching
-- * improve perf when jumping to file
-- * optimize tailer to output buffer when it gets a complete log json entry,
--   instead of waiting for the end of the response to output.

local View = require("slog.view")
local config = require("slog.config")
local colors = require("slog.colors")
local util = require("slog.util")

local Slog = {}

local view

local function is_open()
  return view and view:is_valid()
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
    'SlogClean',
    Slog.clean,
    {}
  )
end

function Slog.open(opts)
  opts = opts or {}
  if is_open() then
    view:update(opts)
  else
    view = View.create(opts)
  end
end

function Slog.close()
  if is_open() then
    view:close()
  end
end

function Slog.toggle(opts)
  if is_open() then
    Slog.close()
  else
    Slog.open(opts)
  end
end

function Slog.clean()
  if is_open() then
    view:clean()
  end
end

function Slog.action(action)
  if not is_open() then
    return Slog
  end

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
  elseif action == "on_enter" then
    view:on_enter()
  elseif action == "on_leave" then
    view:on_leave()
  elseif action == "close" then
    Slog.close()
  elseif action == "cancel" then
    view:switch_to_parent()
  elseif action == "next" then
    view:next_item()
  elseif action == "previous" then
    view:previous_item()
  elseif action == "preview" then
    view:preview()
  elseif action == "toggle_filter" then
    view:toggle_filter()
  else
    util.error("Action '".. action .. "' doesn't exist.")
  end

  return Slog
end

return Slog
