-- TODO
-- * [done] Replace all Trouble references with Slog
-- * [done] Improve colors to better match web slog
-- * [done] Quick filter functionality
-- * Filter functionality/command
-- * online/offline checks? (might need the tailer to signal that)
-- * inform if process stops working
-- * Improve re-renders with better UI caching
-- * fix open vsplit, tab etc on jump
-- * use signs when previewing files to highlight the line http://vimdoc.sourceforge.net/htmldoc/sign.html
--   https://stackoverflow.com/questions/2150220/how-do-i-make-vim-syntax-highlight-a-whole-line
-- * When there are filters applied, show number of hidden messages (maybe on buffer title)
-- * Allow jumping to definition on some of the special base64json elements
-- * Improve perf when jumping to file
-- * Optimize tailer to output buffer when it gets a complete log json entry,
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
end

function Slog.close()
  if is_open() then
    view:close()
  end
end

function Slog.clear()
  if is_open() then
    view:clear()
  end
end

function Slog.open(opts)
  opts = opts or {}
  opts.focus = true
  if is_open() then
    Slog.refresh(opts)
  else
    view = View.create(opts)
  end
end

function Slog.toggle(opts)
  if is_open() then
    Slog.close()
  else
    Slog.open(opts)
  end
end

function Slog.refresh(opts)
  opts = opts or {}
  if is_open() then
    util.debug("refresh")
    view:update(opts)
  end
end

function Slog.next(opts)
  if view then
    view:next_item(opts)
  end
end

function Slog.previous(opts)
  if view then
    view:previous_item(opts)
  end
end

function Slog.get_items()
  if view then
    return view.items
  end
  return {}
end

function Slog.action(action)
  if view and action == "on_win_enter" then
    view:on_win_enter()
  end
  if not is_open() then
    return Slog
  end
  if action == "hover" then
    view:hover()
  end
  if action == "jump" then
    view:jump()
  elseif action == "open_split" then
    view:jump({ precmd = "split" })
  elseif action == "open_vsplit" then
    view:jump({ precmd = "vsplit" })
  elseif action == "open_tab" then
    view:jump({ precmd = "tabe" })
  end
  if action == "jump_close" then
    view:jump()
    Slog.close()
  end
  if action == "close_folds" then
    Slog.refresh({ close_folds = true })
  end
  if action == "toggle_fold" then
    view:toggle_fold()
  end
  if action == "on_enter" then
    view:on_enter()
  end
  if action == "on_leave" then
    view:on_leave()
  end
  if action == "cancel" then
    view:switch_to_parent()
  end
  if action == "next" then
    view:next_item()
    return Slog
  end
  if action == "previous" then
    view:previous_item()
    return Slog
  end
  if action == "preview" then
    view:preview()
  end
  if action == "toggle_filter" then
    view:toggle_filter()
  end

  if Slog[action] then
    Slog[action]()
  end
  return Slog
end

return Slog
