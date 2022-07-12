local config = require('slog.config')

local M = {}

-- TODO allow cache to be cleared.
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

function M.jump_to_item(win, item)
  if not item then
    return
  end
  if item.is_top_level == true or item.fileName == nil then
    return
  end

  -- requiring here, as otherwise we run into a circular dependency
  local View = require('slog.view')

  if vim.fn.filereadable(item.fileName) > 0 then
    View.switch_to(win)
    vim.cmd('edit +' .. item.fileLine .. ' ' .. item.fileName)
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

return M
