local FloatWin = require('slog.float_win')
local Text = require('slog.text')
local AutoCancelTimer = require('slog.auto_cancel_timer')

local StatusPanel = {}
StatusPanel.__index = StatusPanel

-- Float window that shows connection status
function StatusPanel:new(opts)
  opts = vim.tbl_deep_extend('keep', opts, {
    position = 'topright'
  })
  local this = {
    win = FloatWin:new(opts),
    timer = AutoCancelTimer:new(5000),
    is_connected = true
  }
  setmetatable(this, self)
  this:set_is_likely_connected(true)
  return this
end

function StatusPanel:set_is_likely_connected(is_connected)
  local is_state_change = self.is_connected ~= is_connected
  self.is_connected = is_connected

  -- When disconnected, we want to keep showing the status
  -- if connected, we'll only want to show it if we are changing from
  -- disconnected to connected.
  if not is_connected or is_state_change then
    if is_state_change then
      local text = Text:new()
      text:render(' ')
      if is_connected then
        text:render('直on', 'ConnectionSuccess')
      else
        -- ideally blinking (seriously)
        text:render('睊off', 'ConnectionError')
      end
      text:nl()
      self.win:render(text)
    end
    self.win:open()

    self.timer:clear()
    if is_connected then
      self.timer:defer_fn(function()
        self.win:close()
      end)
    end
  end

end

return StatusPanel
