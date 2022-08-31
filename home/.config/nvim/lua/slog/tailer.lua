local util = require('slog.util')

local M = {}

local tailer_job = nil

function M.start(opts, callback)
  if tailer_job ~= nil then
    return
  end

  if opts.tier == nil then
    util.error("We weren't able to detect a tier and none was provided.")
    return
  end

  local filename = debug.getinfo(1).source:sub(2)
  local parent_directory_path = util.parentdir(filename)
  local tailer_path = parent_directory_path .. '/tailer.mjs'

  tailer_job = util.create_async_job(
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

function M.shutdown()
  if tailer_job ~= nil then
    tailer_job:shutdown()
    tailer_job = nil
  end
end

return M
