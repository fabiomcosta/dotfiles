local Job = require('plenary.job')
local util = require('slog.util')

local M = {}

local function create_async_job(cmd, callback)
  local command = table.remove(cmd, 1)
  local args = cmd
  local job = Job:new({
    command = command,
    args = args,
    on_stderr = callback,
    on_stdout = callback,
  })
  job:start()
  return job
end

local function parentdir(path)
  return vim.fn.fnamemodify(path, ':h')
end

function M.get(opts, callback)
  local filename = debug.getinfo(1).source:sub(2)
  local parent_directory_path = parentdir(filename)
  local tailer_path = parent_directory_path .. '/tailer.mjs'

  return create_async_job(
    { 'node', tailer_path, opts.tier },
    function(error, result)
      vim.schedule(function()
        if error ~= nil then
          util.error(error)
        elseif result ~= nil then
          local jsonParsedSuccessfully, jsonOrError = pcall(vim.json.decode, result)
          if jsonParsedSuccessfully then
            callback(jsonOrError)
          else
            util.error(jsonOrError)
          end
        end
      end)
    end
  )
end

function M.group(items)
  return items
end

return M
