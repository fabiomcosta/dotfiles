local config = require('slog.config')
local Job = require('plenary.job')

local M = {}

local function identity(a1)
  return a1
end

-- See https://www.lua.org/pil/17.1.html
function M.memoize(fn, cache_key_gen)
  cache_key_gen = cache_key_gen or identity
  local cache = {}
  setmetatable(cache, { __mode = 'kv' })
  return function(...)
    local args = { ... }
    local cache_key = cache_key_gen(unpack(args))
    if type(cache_key) ~= 'string' then
      return error('Cache key needs to be a string.')
    end
    if cache[cache_key] == vim.NIL then
      return nil
    end
    if cache[cache_key] ~= nil then
      return cache[cache_key]
    end
    local result = fn(unpack(args))
    cache[cache_key] = result == nil and vim.NIL or result
    return result
  end
end

function M.count(tab)
  local count = 0
  for _ in pairs(tab) do
    count = count + 1
  end
  return count
end

function M.info(msg)
  vim.notify(msg, vim.log.levels.INFO, { title = "slog" })
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

function M.create_async_job(opts)
  local command = table.remove(opts.cmd, 1)
  local args = opts.cmd
  local callback = vim.schedule_wrap(opts.callback)
  local job = Job:new({
    command = command,
    args = args,
    writer = opts.writer,
    on_stderr = callback,
    on_stdout = callback,
  })
  job:start()
  return job
end

function M.parentdir(path)
  return vim.fn.fnamemodify(path, ':h')
end

return M
