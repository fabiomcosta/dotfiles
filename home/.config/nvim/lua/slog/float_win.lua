local config = require('slog.config')

local function tbl_max_length(tbl)
  local length = 1
  for _, item in ipairs(tbl) do
    if #item > length then
      length = #item
    end
  end
  return length
end

local POSITION = {
  topright = {
    anchor = 'NW',
    row = 0,
    col = 10000000, -- far right, max possible -- vim.fn.winwidth(self.win),
  },
  bottomright = {
    anchor = 'SW',
    row = 10000000, -- far bottom, max possible
    col = 10000000, -- far right, max possible
  }
}

local FloatWin = {}
FloatWin.__index = FloatWin

-- Float window, like popups.
function FloatWin:new(opts)
  opts = vim.tbl_deep_extend('keep', opts, {
    position = 'topright'
  })
  local this = {
    opts = opts,
    win = nil,
    buf = vim.api.nvim_create_buf(false, true),
  }
  setmetatable(this, self)
  return this
end

function FloatWin:open()
  if self.win ~= nil then
    return
  end
  local position = POSITION[self.opts.position]
  local lines = vim.api.nvim_buf_get_lines(self.buf, 0, -1, true)

  self.win = vim.api.nvim_open_win(self.buf, false, {
    win = self.opts.relative_win or 0,
    relative = 'win',
    anchor = position.anchor,
    row = position.row,
    col = position.col,
    width = tbl_max_length(lines),
    height = #lines,
    focusable = false,
    style = 'minimal'
  })
  vim.api.nvim_win_set_option(self.win, "winfixwidth", true)
  vim.api.nvim_win_set_option(self.win, "winfixheight", true)
end

function FloatWin:close()
  if self.win == nil then
    return
  end
  vim.api.nvim_win_close(self.win, true)
  self.win = nil
end

function FloatWin:render(text)
  vim.api.nvim_buf_set_lines(self.buf, 0, -1, false, text.lines)
  vim.api.nvim_buf_clear_namespace(self.buf, config.namespace, 0, -1)
  for _, hl in ipairs(text.hl) do
    vim.api.nvim_buf_add_highlight(self.buf, config.namespace, hl.group, hl.line, hl.from, hl.to)
  end
end

return FloatWin
