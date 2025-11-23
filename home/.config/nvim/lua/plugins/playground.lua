---@diagnostic disable

-- local pa = require('plenary.async')
-- TODO: play with error handling

-- To me https://github.com/ms-jpq/lua-async-await is THE
-- async library that should be the standard at this point.
-- plenary's is awkward to use and doesn't make the async call explict,
-- it's as if you were calling a sync function.
--
-- local a = require "async"
-- local do_thing = a.sync(function (val)
--   local o = a.wait(async_func())
--   return o + val
-- end)

-- local main = a.sync(function ()
--   local thing = a.wait(do_thing()) -- composable!

--   local x = a.wait(async_func())
--   local y, z = a.wait_all{async_func(), async_func()}
-- end)

-- main()
--
-- Atomic async "object" options:
-- * thunk (simplest)
-- * promise (familiar to JS folks, but not native to lua)
-- * thread? (is this possible?)

-- # API async/await
--
-- ## Function definition
--
-- local async_fn = async function()
--   return await p(3)
-- end
--
-- OR
--
-- local fn = function(cb)
--   p(3).then(cb)
-- end
-- local async_fn = wrap(fn)
--
-- ## Root function
--
-- local async_main = async function()
--   return await async_fn(1, 2)
-- end
--
-- async_main()
--
-- # API async iterators
--
--#################### ############ ####################
--#################### Async Region ####################
--#################### ############ ####################

local co = coroutine

local function p(...)
  print(unpack(vim.tbl_map(vim.inspect, { ... })))
  -- print(debug.traceback())
  --   local status, error = xpcall(func, debug.traceback)
  --   if not status then trace(error) end
end

--#################### UTILS ####################

function create_callable(func, props)
  return setmetatable(props or {}, {
    __call = func,
  })
end

local function is_callable(fn)
  return type(fn) == 'function'
      or (type(fn) == 'table' and type(getmetatable(fn).__call) == 'function')
end

local function assert_callable(func)
  assert(
    is_callable(func),
    'type error :: expected func or table with __call property'
  )
end

--#################### END UTILS ####################

-- use with wrap
local pong = function(func, callback)
  local thread = co.create(func)
  local step
  step = function(...)
    local stat, ret = co.resume(thread, ...)
    assert(stat, ret)
    if co.status(thread) == 'dead' then
      return (callback or function() end)(ret)
    end
    return ret(step)
  end
  return step()
end

-- use with pong, creates thunk factory
local wrap = create_callable(function(self, func)
  return function(...)
    local params = { ... }
    return function(step)
      table.insert(params, step)
      return func(unpack(params))
    end
  end
end)

local thunk_factory = wrap(pong)
local async = function(func, callback)
  return function(...)
    -- This check allows the async function to be the root async function,
    -- else it would never run.
    -- TODO this needs to improve because we need to make sure this is actually
    -- our coroutine that is running, not any coroutine.
    -- ^ do we really though?
    local params = { ... }
    local async_func = function()
      return func(unpack(params))
    end
    if not co.running() then
      return pong(async_func, callback)
    end
    return thunk_factory(async_func)
  end
end

local await = create_callable(function(self, defer)
  assert_callable(defer)
  return co.yield(defer)
end)

local a = {
  sync = async,
  wait = await,
  wrap = wrap,
}

--#################### START JOIN ####################

local function identity(a1)
  return a1
end

local function first(a1)
  return a1[1]
end

local join = function(thunks, map)
  map = map or identity
  local len = #thunks
  local done = 0
  local acc = {}
  return function(step)
    if len == 0 then
      return step()
    end
    for i, tk in ipairs(thunks) do
      assert_callable(tk)
      local callback = function(...)
        acc[i] = map({ ... })
        done = done + 1
        if done == len then
          step(unpack(acc))
        end
      end
      tk(callback)
    end
  end
end

await.all = function(defer, map)
  assert(type(defer) == 'table', 'type error :: expected table')
  return await(join(defer, map))
end

--#################### END JOIN ####################

--#################### START ASYNC ITER ####################

-- Only lets this method be called once.
-- the following calls ignore the wrapped function and simply return nil.
local once = function(func)
  local called = nil
  return function(...)
    if called == nil then
      called = true
      return func(...)
    end
  end
end

-- TODO add options, like timeout that will throw or maybe that will force
-- the iterator to stop.
wrap.iter = function(func)
  local thunk_factory = wrap(func)
  return async(function(...)
    local thunk = once(thunk_factory(...))
    return function()
      return await(thunk)
    end
  end)
end

--#################### END ASYNC ITER ####################

-- local defer = wrap(function(timeout, done)
--   vim.schedule(function()
--     done(timeout, 900)
--   end)
-- end)

-- local defer_iter = wrap.iter(function(timeout, done)
--   -- done(timeout)
--   -- done(300)
--   -- done(nil)
--   vim.schedule(function()
--     done(timeout)
--   end)
--   vim.schedule(function()
--     done(300)
--   end)
--   vim.schedule(function()
--     done(nil)
--   end)
-- end)

--async(function()
--  print('before')
--  p(await(defer(100)))
--  for y in await(defer_iter(12)) do
--    p('y', y)
--    --for x in await(defer_iter2(14)) do
--    --  p('x', x)
--    --end
--  end
--  p(await(defer(100)))
--  print('after')
--end)()

-- function iter()
--   local function step()
--     coroutine.yield(1, 2, 3)
--     coroutine.yield(4, 5, 6)
--   end
--   return coroutine.wrap(step)
-- end

--
-- vim.print('a')
-- for x, y, z in iter() do
--   for x, y, z in iter() do
-- for x, y, z in iter() do
-- vim.print({ x, y, z })
-- end
--   end
-- end
-- vim.print('b')

-- local function find_all(str, pattern, start_pos)
--   start_pos = start_pos or 1
--   return function()
--     local start, _end = str:find(pattern, start_pos)
--     if start == nil then
--       return
--     end
--     start_pos = _end + 1
--     return start, _end
--   end
-- end
--
-- local text = 'fabio-m\nfabio-m\nfabio-m'
-- for start_pos, end_pos in find_all(text, 'fabio%-[^\n]*') do
--   vim.notify(vim.inspect({ start_pos, end_pos }))
-- end

return {}
