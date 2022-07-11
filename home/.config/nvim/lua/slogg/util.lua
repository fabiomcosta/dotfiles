local config = require('slog.config')

local M = {}

local NIL = {}
function M.memoize(fn, cache_key_gen)
  cache_key_gen = cache_key_gen or function(a1)
    return a1
  end
  local cache = {}
  return function(...)
    local arg = { ... }
    local cache_key = cache_key_gen(unpack(arg))
    if cache_key == nil then
      return error("Cache key can't be nil.")
    end
    if cache[cache_key] == NIL then
      return nil
    end
    if cache[cache_key] ~= nil then
      return cache[cache_key]
    end
    local result = fn(unpack(arg))
    if result == nil then
      cache[cache_key] = NIL
    else
      cache[cache_key] = result
    end
    return result
  end
end

function M.jump_to_item(win, precmd, item)
  -- requiring here, as otherwise we run into a circular dependency
  local View = require('slog.view')

  View.switch_to(win)
  if precmd then
    vim.cmd(precmd)
  end
  if vim.api.nvim_buf_get_option(item.bufnr, "buflisted") == false then
    vim.cmd("edit #" .. item.bufnr)
  else
    vim.cmd("buffer " .. item.bufnr)
  end
  vim.api.nvim_win_set_cursor(win, { item.start.line + 1, item.start.character })
end

function M.fix_mode(opts)
  if opts.use_lsp_diagnostic_signs then
    opts.use_diagnostic_signs = opts.use_lsp_diagnostic_signs
    M.warn("The Trouble option use_lsp_diagnostic_signs has been renamed to use_diagnostic_signs")
  end
  local replace = {
    lsp_workspace_diagnostics = "workspace_diagnostics",
    lsp_document_diagnostics = "document_diagnostics",
    workspace = "workspace_diagnostics",
    document = "document_diagnostics",
  }

  for old, new in pairs(replace) do
    if opts.mode == old then
      opts.mode = new
      M.warn("Using " .. old .. " for Trouble is deprecated. Please use " .. new .. " instead.")
    end
  end
end

function M.count(tab)
  local count = 0
  for _ in pairs(tab) do
    count = count + 1
  end
  return count
end

function M.warn(msg)
  vim.notify(msg, vim.log.levels.WARN, { title = "slog" })
end

function M.error(msg)
  vim.notify(msg, vim.log.levels.ERROR, { title = "slog" })
end

function M.debug(msg)
  if config.options.debug then
    vim.notify(msg, vim.log.levels.DEBUG, { title = "slog" })
  end
end

function M.debounce(ms, fn)
  local timer = vim.loop.new_timer()
  return function(...)
    local argv = { ... }
    timer:start(ms, 0, function()
      timer:stop()
      vim.schedule_wrap(fn)(unpack(argv))
    end)
  end
end

function M.throttle(ms, fn)
  local timer = vim.loop.new_timer()
  local running = false
  return function(...)
    if not running then
      local argv = { ... }
      local argc = select("#", ...)

      timer:start(ms, 0, function()
        running = false
        pcall(vim.schedule_wrap(fn), unpack(argv, 1, argc))
      end)
      running = true
    end
  end
end

M.severity = {
  [0] = "Other",
  [1] = "Error",
  [2] = "Warning",
  [3] = "Information",
  [4] = "Hint",
}

-- returns a hl or sign label for the givin severity and type
-- correctly handles new names introduced in vim.diagnostic
function M.get_severity_label(severity, type)
  local label = severity
  local prefix = "LspDiagnostics" .. (type or "Default")

  if vim.diagnostic then
    prefix = type and ("Diagnostic" .. type) or "Diagnostic"
    label = ({
      Warning = "Warn",
      Information = "Info",
    })[severity] or severity
  end

  return prefix .. label
end

-- based on the Telescope diagnostics code
-- see https://github.com/nvim-telescope/telescope.nvim/blob/0d6cd47990781ea760dd3db578015c140c7b9fa7/lua/telescope/utils.lua#L85

function M.process_item(item, bufnr)
  bufnr = bufnr or item.bufnr
  local filename = vim.api.nvim_buf_get_name(bufnr)
  local uri = vim.uri_from_bufnr(bufnr)
  local range = item.range
      or item.targetSelectionRange
      or {
        ["start"] = {
          character = item.col,
          line = item.lnum,
        },
        ["end"] = {
          character = item.end_col,
          line = item.end_lnum,
        },
      }
  local start = range["start"]
  local finish = range["end"]

  if start.character == nil or start.line == nil then
    M.error("Found an item for Trouble without start range " .. vim.inspect(start))
  end
  if finish.character == nil or finish.line == nil then
    M.error("Found an item for Trouble without finish range " .. vim.inspect(finish))
  end
  local row = start.line
  local col = start.character

  if not item.message then
    local line
    if vim.lsp.util.get_line then
      line = vim.lsp.util.get_line(uri, row)
    else
      -- load the buffer when needed
      vim.fn.bufload(bufnr)
      line = (vim.api.nvim_buf_get_lines(bufnr, row, row + 1, false) or { "" })[1]
    end

    item.message = item.message or line or ""
  end

  ---@class Item
  ---@field is_file boolean
  ---@field fixed boolean
  local ret
  ret = {
    bufnr = bufnr,
    filename = filename,
    lnum = row + 1,
    col = col + 1,
    start = start,
    finish = finish,
    sign = item.sign,
    sign_hl = item.sign_hl,
    -- remove line break to avoid display issues
    text = vim.trim(item.message:gsub("[\n]", "")):sub(0, vim.o.columns),
    full_text = vim.trim(item.message),
    type = M.severity[item.severity] or M.severity[0],
    code = item.code or (item.user_data and item.user_data.lsp and item.user_data.lsp.code),
    source = item.source,
    severity = item.severity or 0,
  }
  return ret
end

-- takes either a table indexed by bufnr, or an lsp result with uri
---@return Item[]
function M.locations_to_items(results, default_severity)
  default_severity = default_severity or 0
  local ret = {}
  for bufnr, locs in pairs(results or {}) do
    for _, loc in pairs(locs.result or locs) do
      if not vim.tbl_isempty(loc) then
        local uri = loc.uri or loc.targetUri
        local buf = uri and vim.uri_to_bufnr(uri) or bufnr
        loc.severity = loc.severity or default_severity
        table.insert(ret, M.process_item(loc, buf))
      end
    end
  end
  return ret
end

-- @private
local function make_position_param(win, buf)
  local row, col = unpack(vim.api.nvim_win_get_cursor(win))
  row = row - 1
  local line = vim.api.nvim_buf_get_lines(buf, row, row + 1, true)[1]
  if not line then
    return { line = 0, character = 0 }
  end
  col = vim.str_utfindex(line, col)
  return { line = row, character = col }
end

function M.make_text_document_params(buf)
  return { uri = vim.uri_from_bufnr(buf) }
end

--- Creates a `TextDocumentPositionParams` object for the current buffer and cursor position.
---
-- @returns `TextDocumentPositionParams` object
-- @see https://microsoft.github.io/language-server-protocol/specifications/specification-current/#textDocumentPositionParams
function M.make_position_params(win, buf)
  return {
    textDocument = M.make_text_document_params(buf),
    position = make_position_param(win, buf),
  }
end

return M
