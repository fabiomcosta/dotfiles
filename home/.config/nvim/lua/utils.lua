local function identity(a1)
  return a1
end

-- See https://www.lua.org/pil/17.1.html
local function memoize(fn, cache_key_gen)
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

-- local function system(cmd, opts)
--   local stdout, exit_code, stderr = get_os_command_output(cmd, opts)
--   if exit_code ~= 0 then
--     return error(
--       'stderr: ' .. vim.inspect(stderr) .. '\nstdout: ' .. vim.inspect(stdout)
--     )
--   end
--   return vim.trim(stdout[1] or '')
-- end

local function get_os_command_output(cmd, opts)
  local Job = require('plenary.job')
  opts = opts or {}
  local command = table.remove(cmd, 1)
  local stderr = {}
  local stdout, ret = Job:new({
    command = command,
    args = cmd,
    cwd = opts.cwd,
    on_stderr = function(_, data)
      table.insert(stderr, data)
    end,
  }):sync(opts.timeout)
  return stdout, ret, stderr
end

local function is_system_success(cmd, opts)
  local _, exit_code = get_os_command_output(cmd, opts)
  return exit_code == 0
end

local is_hg_repo_in_cwd = memoize(function(cwd)
  return is_system_success({ 'hg', 'root' }, { cwd = cwd })
end)

local is_biggrep_repo_in_cwd = memoize(function(cwd)
  local is_success, _, exit_code, stderr = pcall(
    get_os_command_output,
    { 'bgs' },
    { cwd = cwd }
  )
  if not is_success then
    return false
  end
  if exit_code ~= 0 then
    return not vim.startswith(vim.trim(stderr[1]), 'Error:')
  end
  return false
end)

local is_myles_repo_in_cwd = memoize(function(cwd)
  -- This makes sure to start myles if it hasn't been started yet.
  pcall(
    get_os_command_output,
    -- '.hg' here is "random", it could be anything
    { 'myles', '--list', '.hg' },
    { cwd = cwd }
  )
  local is_success, stdout, exit_code, stderr = pcall(
    get_os_command_output,
    { 'myles', 'rage' },
    { cwd = cwd }
  )
  if is_success then
    for _, text in ipairs(stdout) do
      lower_text = string.lower(text)
      if string.find(lower_text, 'is supported') then
        is_supported = vim.split(lower_text, ':')[2]
        return vim.trim(is_supported) ~= 'false'
      end
    end
  end
  return false
end)

local utils = {
  get_os_command_output = get_os_command_output,
}

function utils.is_hg_repo()
  return is_hg_repo_in_cwd(vim.loop.cwd())
end

function utils.is_biggrep_repo()
  return is_biggrep_repo_in_cwd(vim.loop.cwd())
end

function utils.is_myles_repo()
  return is_myles_repo_in_cwd(vim.loop.cwd())
end

function utils.replace_termcodes(str)
  return vim.api.nvim_replace_termcodes(str, true, false, true)
end

-- local function feedkeys(key, mode)
--   mode = mode or 'x'
--   vim.api.nvim_feedkeys(replace_termcodes(key), mode, false)
-- end

function utils.module_exists(module_name)
  return pcall(require, module_name)
end

function utils.require_if_exists(module_name, callback)
  local exists, module = pcall(require, module_name)
  if exists then
    callback(module)
  end
end

function utils.tbl_contains(table, element)
  for _, value in pairs(table) do
    if value == element then
      return true
    end
  end
  return false
end

function utils.joinpath(...)
  local args = { ... }
  if vim.fs.joinpath ~= nil then
    return vim.fs.joinpath(unpack(args))
  end
  return vim.fn.join(args, '/')
end

return utils
