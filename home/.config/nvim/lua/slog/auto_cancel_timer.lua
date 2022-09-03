local AutoCancelTimer = {}
AutoCancelTimer.__index = AutoCancelTimer

function AutoCancelTimer:new(timeout)
  local this = {
    timer = nil,
    timeout = timeout
  }
  setmetatable(this, self)
  return this
end

function AutoCancelTimer:clear()
  if self.timer == nil then
    return
  end
  self.timer:stop()
  -- self.timer:close()
  self.timer = nil
end

function AutoCancelTimer:defer_fn(callback)
  if self.timer ~= nil then
    self:clear()
  end
  self.timer = vim.defer_fn(function()
    callback()
    self:clear()
  end, self.timeout)
end

return AutoCancelTimer
