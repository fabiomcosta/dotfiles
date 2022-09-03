local config = require('slog.config')
local util = require('slog.util')
local Text = require('slog.text')
local AutoCancelTimer = require('slog.auto_cancel_timer')

local function clear_highlight(bufnr)
  if not vim.api.nvim_buf_is_valid(bufnr) then
    return
  end
  vim.api.nvim_buf_clear_namespace(bufnr, config.namespace, 0, -1)
end

local StatusPanel = {}
StatusPanel.__index = StatusPanel

-- float with server name and connection status
function StatusPanel:new(opts)
  opts = opts or {}
  local this = {
    opts = opts,
    win = nil,
    buf = vim.api.nvim_create_buf(false, true),
    timer = AutoCancelTimer:new(5000),
    is_connected = true
  }
  setmetatable(this, self)
  this:set_is_likely_connected(true)
  return this
end

function StatusPanel:open_win()
  if self.win ~= nil then
    return
  end

  self.win = vim.api.nvim_open_win(self.buf, false, {
    win = self.opts.relative_win or 0,
    relative = 'win',
    anchor = 'NW',
    row = 0,
    col = 10000000, -- far right, max possible -- vim.fn.winwidth(self.win),
    width = 6,
    height = 1,
    focusable = false,
    style = 'minimal'
  })
  vim.api.nvim_win_set_option(self.win, "winfixwidth", true)
  vim.api.nvim_win_set_option(self.win, "winfixheight", true)
end

function StatusPanel:close_win()
  if self.win == nil then
    return
  end
  vim.api.nvim_win_close(self.win, true)
  self.win = nil
end

function StatusPanel:set_is_likely_connected(is_connected)
  -- When disconnected, we want to keep showing the status
  -- if connected, we'll only want to show it if we are changing from
  -- disconnected to connected.
  util.debug('set_is_likely_connected ' .. tostring(is_connected))
  if not is_connected or self.is_connected ~= is_connected then
    self:open_win()
    self.timer:clear()
    if is_connected then
      self.timer:defer_fn(function()
        self:close_win()
      end)
    end
  end

  local is_state_change = self.is_connected ~= is_connected
  self.is_connected = is_connected

  if not is_state_change then
    return
  end

  local text = Text:new()
  text:render(' ')
  if is_connected then
    text:render('直on', 'ConnectionSuccess')
  else
    -- ideally blinking (seriously)
    text:render('睊off', 'ConnectionError')
  end
  text:nl()

  vim.api.nvim_buf_set_lines(self.buf, 0, -1, false, text.lines)
  clear_highlight(self.buf)
  for _, hl in ipairs(text.hl) do
    vim.api.nvim_buf_add_highlight(self.buf, config.namespace, hl.group, hl.line, hl.from, hl.to)
  end
end

return StatusPanel
