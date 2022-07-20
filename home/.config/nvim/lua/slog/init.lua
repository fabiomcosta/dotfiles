local View = require("slog.view")
local config = require("slog.config")
local colors = require("slog.colors")
local util = require("slog.util")

local Trouble = {}

local view

local function is_open()
  return view and view:is_valid()
end

function Trouble.setup(options)
  config.setup(options)
  colors.setup()
end

function Trouble.close()
  if is_open() then
    view:close()
  end
end

function Trouble.open(opts)
  opts = opts or {}
  opts.focus = true
  if is_open() then
    Trouble.refresh(opts)
  else
    view = View.create(opts)
  end
end

function Trouble.toggle(opts)
  if is_open() then
    Trouble.close()
  else
    Trouble.open(opts)
  end
end

function Trouble.refresh(opts)
  opts = opts or {}
  if is_open() then
    util.debug("refresh")
    view:update(opts)
  end
end

function Trouble.action(action)
  if view and action == "on_win_enter" then
    view:on_win_enter()
  end
  if not is_open() then
    return Trouble
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
    Trouble.close()
  end
  if action == "open_folds" then
    Trouble.refresh({ open_folds = true })
  end
  if action == "close_folds" then
    Trouble.refresh({ close_folds = true })
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
    return Trouble
  end
  if action == "previous" then
    view:previous_item()
    return Trouble
  end

  if action == "toggle_preview" then
    config.options.auto_preview = not config.options.auto_preview
    if not config.options.auto_preview then
      view:close_preview()
    else
      action = "preview"
    end
  end
  if action == "auto_preview" and config.options.auto_preview then
    action = "preview"
  end
  if action == "preview" then
    view:preview()
  end

  if Trouble[action] then
    Trouble[action]()
  end
  return Trouble
end

function Trouble.next(opts)
  if view then
    view:next_item(opts)
  end
end

function Trouble.previous(opts)
  if view then
    view:previous_item(opts)
  end
end

function Trouble.get_items()
  if view ~= nil then
    return view.items
  end
  return {}
end

return Trouble
