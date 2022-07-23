local util = require('slog.util')

local M = {}

function M.tail_logs(opts, callback)
  local filename = debug.getinfo(1).source:sub(2)
  local parent_directory_path = util.parentdir(filename)
  local tailer_path = parent_directory_path .. '/tailer.mjs'

  return util.create_async_job(
    { 'node', tailer_path, opts.tier },
    function(error, result)
      vim.schedule(function()
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

return M
