local renderer = require('slog.renderer')
local config = require('slog.config')
local folds = require('slog.folds')
local util = require('slog.util')
local preview_sign = require('slog.preview_sign')

local highlight = vim.api.nvim_buf_add_highlight

---@class SlogView
---@field buf number
---@field win number
---@field items Item[]
---@field folded table<string, boolean>
---@field parent number
---@field float number
local View = {}
View.__index = View

-- keep track of buffers with added highlights
-- highlights are cleared on BufLeave of Trouble
local hl_bufs = {}

local function clear_hl(bufnr)
  if vim.api.nvim_buf_is_valid(bufnr) then
    vim.api.nvim_buf_clear_namespace(bufnr, config.namespace, 0, -1)
  end
end

local function find_rogue_buffer()
  for _, v in ipairs(vim.api.nvim_list_bufs()) do
    if vim.fn.bufname(v) == "slog for " .. config.options.tier then
      return v
    end
  end
  return nil
end

local function wipe_rogue_buffer()
  local bn = find_rogue_buffer()
  if bn then
    local win_ids = vim.fn.win_findbuf(bn)
    for _, id in ipairs(win_ids) do
      if vim.fn.win_gettype(id) ~= "autocmd" and vim.api.nvim_win_is_valid(id) then
        vim.api.nvim_win_close(id, true)
      end
    end

    vim.api.nvim_buf_set_name(bn, "")
    vim.schedule(function()
      pcall(vim.api.nvim_buf_delete, bn, {})
    end)
  end
end

local function is_float(win)
  local opts = vim.api.nvim_win_get_config(win)
  return opts and opts.relative and opts.relative ~= ""
end

function View:new(opts)
  opts = opts or {}
  local this = {
    buf = vim.api.nvim_get_current_buf(),
    win = opts.win or vim.api.nvim_get_current_win(),
    parent = opts.parent,
    filters = opts.filters,
    items = {},
  }
  setmetatable(this, self)
  return this
end

function View:set_option(name, value)
  return vim.api.nvim_buf_set_option(self.buf, name, value)
end

function View:set_win_option(name, value)
  return vim.api.nvim_win_set_option(self.win, name, value)
end

---@param text Text
function View:render(text)
  self:unlock()
  self:set_lines(text.lines)
  self:lock()
  clear_hl(self.buf)
  for _, data in ipairs(text.hl) do
    highlight(self.buf, config.namespace, data.group, data.line, data.from, data.to)
  end
end

function View:clean()
  renderer.clean(self)
end

function View:unlock()
  self:set_option("modifiable", true)
  self:set_option("readonly", false)
end

function View:lock()
  self:set_option("readonly", true)
  self:set_option("modifiable", false)
end

function View:set_lines(lines, first, last, strict)
  first = first or 0
  last = last or -1
  strict = strict or false
  return vim.api.nvim_buf_set_lines(self.buf, first, last, strict, lines)
end

function View:is_valid()
  return vim.api.nvim_buf_is_valid(self.buf) and vim.api.nvim_buf_is_loaded(self.buf)
end

function View:update()
  renderer.render(self)
end

function View:setup(opts)
  util.debug("setup")
  opts = opts or {}
  vim.cmd("setlocal nonu")
  vim.cmd("setlocal nornu")
  local tier = config.options.tier
  local buf_name = tier and 'slog for ' .. tier or 'slog'
  if not pcall(vim.api.nvim_buf_set_name, self.buf, buf_name) then
    wipe_rogue_buffer()
    vim.api.nvim_buf_set_name(self.buf, buf_name)
  end
  self:set_option("bufhidden", "wipe")
  self:set_option("buftype", "nofile")
  self:set_option("swapfile", false)
  self:set_option("buflisted", false)
  self:set_win_option("winfixwidth", true)
  self:set_win_option("wrap", true)
  self:set_win_option("spell", false)
  self:set_win_option("list", false)
  self:set_win_option("winfixheight", true)
  self:set_win_option("signcolumn", "no")
  self:set_win_option("foldmethod", "manual")
  self:set_win_option("foldcolumn", "0")
  self:set_win_option("foldlevel", 3)
  self:set_win_option("foldenable", false)
  self:set_win_option("winhighlight", "Normal:SlogNormal,EndOfBuffer:SlogNormal,SignColumn:SlogNormal")
  self:set_win_option("fcs", "eob: ")
  self:set_option("filetype", "slog")

  for action, keys in pairs(config.options.action_keys) do
    if type(keys) == "string" then
      keys = { keys }
    end
    for _, key in pairs(keys) do
      vim.api.nvim_buf_set_keymap(self.buf, "n", key, [[<cmd>lua require("slog").action("]] .. action .. [[")<cr>]],
        {
          silent = true,
          noremap = true,
          nowait = true,
        })
    end
  end

  if config.options.position == "top" or config.options.position == "bottom" then
    vim.api.nvim_win_set_height(self.win, config.options.height)
  else
    vim.api.nvim_win_set_width(self.win, config.options.width)
  end

  local augroup = vim.api.nvim_create_augroup('SlogHighlights', { clear = true })

  vim.api.nvim_create_autocmd('BufEnter', {
    group = augroup,
    buffer = self.buf,
    callback = function()
      util.debug('on_enter')
      self:on_enter()
    end
  })

  vim.api.nvim_create_autocmd('BufLeave', {
    group = augroup,
    buffer = self.buf,
    callback = function()
      util.debug('on_leave')
      self:on_leave()
    end
  })

  vim.api.nvim_create_autocmd({'BufUnload', 'BufHidden'}, {
    group = augroup,
    buffer = self.buf,
    callback = function()
      util.debug('unload, hidden')
      renderer.close()
    end
  })

  if not opts.parent then
    self:on_enter()
  end
  self:lock()
  self:update(opts)
end

function View:on_enter()
  self.parent = self.parent or vim.fn.win_getid(vim.fn.winnr("#"))

  if (not self:is_valid_parent(self.parent)) or self.parent == self.win then
    util.debug("not valid parent")
    for _, win in pairs(vim.api.nvim_list_wins()) do
      if self:is_valid_parent(win) and win ~= self.win then
        self.parent = win
        break
      end
    end
  end

  if not vim.api.nvim_win_is_valid(self.parent) then
    return self:close()
  end

  self.parent_state = {
    buf = vim.api.nvim_win_get_buf(self.parent),
    cursor = vim.api.nvim_win_get_cursor(self.parent),
  }
end

function View:on_leave()
  self:close_preview()
end

function View:close_preview()
  -- Clear preview highlights
  for buf, _ in pairs(hl_bufs) do
    clear_hl(buf)
  end
  hl_bufs = {}

  -- Reset parent state
  local valid_win = vim.api.nvim_win_is_valid(self.parent)
  local valid_buf = self.parent_state and vim.api.nvim_buf_is_valid(self.parent_state.buf)

  if self.parent_state and valid_buf and valid_win then
    vim.api.nvim_win_set_buf(self.parent, self.parent_state.buf)
    vim.api.nvim_win_set_cursor(self.parent, self.parent_state.cursor)
  end

  self.parent_state = nil
end

function View:is_valid_parent(win)
  if not vim.api.nvim_win_is_valid(win) then
    return false
  end
  -- dont do anything for floating windows
  if is_float(win) then
    return false
  end
  local buf = vim.api.nvim_win_get_buf(win)
  -- Skip special buffers
  if vim.api.nvim_buf_get_option(buf, "buftype") ~= "" then
    return false
  end

  return true
end

function View.switch_to(win, buf)
  if win then
    vim.api.nvim_set_current_win(win)
    if buf then
      vim.api.nvim_win_set_buf(win, buf)
    end
  end
end

function View:switch_to_parent()
  -- vim.cmd("wincmd p")
  View.switch_to(self.parent)
end

function View:close()
  if vim.api.nvim_win_is_valid(self.win) then
    vim.api.nvim_win_close(self.win, {})
  end
  if vim.api.nvim_buf_is_valid(self.buf) then
    vim.api.nvim_buf_delete(self.buf, {})
  end
  renderer.close()
end

function View.create(opts)
  opts = opts or {}
  if opts.win then
    View.switch_to(opts.win)
    vim.cmd("enew")
  else
    vim.cmd("below new")
    local pos = { bottom = "J", top = "K", left = "H", right = "L" }
    vim.cmd("wincmd " .. (pos[config.options.position] or "K"))
  end
  local buffer = View:new(opts)
  buffer:setup(opts)
  buffer:switch_to_parent()
  return buffer
end

function View:get_cursor()
  return vim.api.nvim_win_get_cursor(self.win)
end

function View:get_line()
  return self:get_cursor()[1]
end

function View:get_col()
  return self:get_cursor()[2]
end

function View:current_item()
  local line = self:get_line()
  return self.items[line]
end

function View:next_item(opts)
  opts = opts or { skip_groups = false }
  local line = self:get_line()
  for i = line + 1, vim.api.nvim_buf_line_count(self.buf), 1 do
    if self.items[i] and not (opts.skip_groups and self.items[i].is_top_level) then
      vim.api.nvim_win_set_cursor(self.win, { i, self:get_col() })
      if opts.jump then
        self:jump()
      end
      return
    end
  end
end

function View:previous_item(opts)
  opts = opts or { skip_groups = false }
  local line = self:get_line()
  for i = line - 1, 0, -1 do
    if self.items[i] and not (opts.skip_groups and self.items[i].is_top_level) then
      vim.api.nvim_win_set_cursor(self.win, { i, self:get_col() })
      if opts.jump then
        self:jump()
      end
      return
    end
  end
end

function View:jump(opts)
  opts = opts or {}
  local item = opts.item or self:current_item()
  if not item then
    return
  end

  if item.is_top_level == true then
    folds.toggle(item.key)
    self:update()
    return
  end

  if item.fileName == nil then
    return
  end

  if vim.fn.filereadable(item.fileName) == 0 then
    return
  end

  local win = opts.win or self.parent
  local precmd = opts.precmd
  -- no reason on keeping any highlight sign once we jump to the file
  preview_sign.unplace_all()
  View.switch_to(win)
  if precmd then
    vim.cmd(precmd)
  end
  vim.cmd('edit +' .. item.fileLine .. ' ' .. item.fileName)
end

function View:toggle_filter()
  local item = self:current_item()
  if item.is_top_level then
    local options = config.options
    if not options.filters.level and item.level then
      options.filters.level = item.level
    else
      options.filters.level = nil
    end
    self:update()
  end
end

function View:place_preview_sign_at_line(lnum)
  preview_sign.place({ buf = self.parent, lnum = lnum })
end

function View:_preview()
  if not vim.api.nvim_win_is_valid(self.parent) then
    return
  end

  local item = self:current_item()
  if not item then
    return
  end
  if item.is_top_level == true or item.fileName == nil then
    return
  end

  -- self.parent doesnt make much sense for our case...
  -- each trace line will possibly have its own buffer (file), so we
  -- have to adapt the code for that.

  local bufnr = vim.api.nvim_win_get_buf(self.parent)
  local filename = vim.api.nvim_buf_get_name(bufnr)

  if filename == item.fileName then
    local cursor = vim.api.nvim_win_get_cursor(self.parent)
    if cursor[1] == item.fileLine + 1 then
      -- we are already in the right place
      return
    end
  end

  if vim.fn.filereadable(item.fileName) == 0 then
    return
  end

  local current_win = vim.api.nvim_get_current_win()
  self:switch_to_parent()
  preview_sign.unplace_all()
  vim.cmd('edit +' .. item.fileLine .. ' ' .. item.fileName)
  self:place_preview_sign_at_line(item.fileLine)
  View.switch_to(current_win)
end

-- View.preview = View._preview

View.preview = util.throttle(50, View._preview)

return View
