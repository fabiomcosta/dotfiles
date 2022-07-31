local util = require('slog.util')

local M = {}

local tailer_job = nil

-- local function set_timeout(timeout, callback)
--   local timer = vim.loop.new_timer()
--   timer:start(timeout, 0, vim.schedule_wrap(function()
--     timer:stop()
--     timer:close()
--     callback()
--   end))
--   return timer
-- end

-- local function clear_timeout(timer)
--   if timer then
--     timer:stop()
--     timer:close()
--   end
-- end

function M.start(opts, callback)
  if tailer_job ~= nil then
    return
  end

  local filename = debug.getinfo(1).source:sub(2)
  local parent_directory_path = util.parentdir(filename)
  local tailer_path = parent_directory_path .. '/tailer.mjs'
  -- local timer = nil

  tailer_job = util.create_async_job(
    { 'node', tailer_path, opts.tier },
    function(error, result)
      vim.schedule(function()
        -- clear_timeout(timer)
        -- timer = set_timeout(40000, function()
        --   callback({ online = false })
        -- end)
        if error ~= nil then
          return util.error(error)
        end
        if result == nil then
          return
        end
        local jsonParsedSuccessfully, jsonOrError = pcall(vim.json.decode, result)
        if not jsonParsedSuccessfully then
          return util.error(jsonOrError)
        end
        callback(jsonOrError)
      end)
    end
  )
end

function M.shutdown(opts, callback)
  if tailer_job ~= nil then
    tailer_job:shutdown()
    tailer_job = nil
  end
end

return M
