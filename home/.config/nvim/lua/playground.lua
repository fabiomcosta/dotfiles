---@diagnostic disable

local function p(...)
  print(unpack(vim.tbl_map(vim.inspect, { ... })))
  -- print(debug.traceback())
  --   local status, error = xpcall(func, debug.traceback)
  --   if not status then trace(error) end
end

-- local pa = require('plenary.async')
local co = coroutine
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

--#################### UTILS ####################

function create_callable(func, props)
  return setmetatable(props or {}, {
    __call = func,
  })
end

local function f(name, func)
  return setmetatable({}, {
    __call = function(self, ...)
      return func(...)
    end,
    __tostring = function()
      return (name or '<NIL>')
    end,
  })
end

local function t(table)
  return setmetatable(table, {
    __tostring = function()
      return '{' .. vim.fn.join(vim.tbl_map(tostring, table), ', ') .. '}'
    end,
  })
end

-- Only lets this method be called once.
-- the followingi  calls ignore the wrapped function and simply return nil.
local once = f('once', function(func)
  local called = nil
  return f('onced_fn:calls->' .. tostring(func), function(...)
    if called == nil then
      called = true
      return func(...)
    end
  end)
end)

local function identity(a1)
  return a1
end

local function first(a1)
  return a1[1]
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

local function n(func)
  if func == nil then
    return '<NIL>'
  end
  if type(func) == 'function' then
    return '<UNNAMED>'
  elseif is_callable(func) then
    return func.name
  end
  return '<UNKOWN>'
end

--#################### END UTILS ####################

local await = f('await', function(defer)
  -- assert_callable(defer)
  return co.yield(defer)
end)

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
      -- assert_callable(tk)
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
  -- assert(type(defer) == 'table', 'type error :: expected table')
  return await(join(defer, map))
end

-- use with wrap
local pong = f('pong', function(func, callback)
  local thread = co.create(func)
  local step
  step = f('step', function(...)
    local stat, ret = co.resume(thread, ...)
    -- assert(stat, ret)
    if co.status(thread) == 'dead' then
      return (callback or function() end)(ret)
    end
    return ret(step)
  end)
  return step()
end)

-- use with pong, creates thunk factory
local wrap = f('wrap', function(func)
  return f('wrapped_fn:' .. tostring(func), function(...)
    local params = t({ ... })
    return f('wrapped_thunk:calls->' .. tostring(func), function(step)
      table.insert(params, step)
      return func(unpack(params))
    end)
  end)
end)

local thunk_factory = wrap(pong)
local async = function(func, callback)
  return f('async_fn:calls->' .. tostring(func), function(...)
    -- This check allows the async function to be the root async function,
    -- else it would never run.
    -- TODO this needs to improve because we need to make sure this is actually
    -- our coroutine that is running, not any coroutine.
    -- ^ do we really though?
    local params = t({ ... })
    local async_func = function()
      return func(unpack(params))
    end
    if not co.running() then
      return pong(async_func, callback)
    end
    return thunk_factory(async_func)
  end)
end

-- TODO add options, like timeout that will throw or maybe that will force
-- the iterator to stop.
wrap.iter = function(func)
  local thunk_factory = wrap(func)
  return async(f('wrap_iter_async:' .. tostring(func), function(...)
    local thunk = once(thunk_factory(...))
    return function()
      return await(thunk)
    end
  end))
end

local a = {
  sync = async,
  wait = await,
  wrap = wrap,
}

local defer = wrap(function(timeout, done)
  vim.schedule(function()
    done(timeout, 900)
  end)
end)

local defer_iter_cb = f('defer_iter_cb', function(timeout, done)
  -- p('PARAMS1!', timeout, done)
  vim.schedule(function()
    done(timeout)
  end)
  vim.schedule(function()
    done(nil)
  end)
  -- vim.defer_fn(function()
  --   done(300)
  -- end, 300)
end)

local defer_iter = wrap.iter(defer_iter_cb)

async(function()
  print('heya')
  for y in await(defer_iter(12)) do
    p('y', y)
  end
  for x in await(defer_iter(12)) do
    p('x', x)
  end
end)()

-- print(t({ 1, 2, 3, 'EITA' }))

-- function defer_iter_cb2(timeout, done)
--   -- p('PARAMS2!', timeout)
--   vim.defer_fn(function()
--     done(timeout)
--   end, timeout)
--   vim.defer_fn(function()
--     done(nil)
--   end, 600)
--   -- vim.defer_fn(function()
--   --   done(300)
--   -- end, 300)
-- end
-- local defer_iter2 = wrap.iter(defer_iter_cb2)

-- local x = async(function(a, b, c)
--   -- p(await(defer(300)))
--   for y in defer_iter(12) do
--     p('y', y)
--     for z in defer_iter2(20) do
--       p('z', z)
--     end
--   end
--   -- p(await(defer(200)))
-- end)

-- local x = async(function()
--   return await(defer(300))
--   -- for x in defer_iter2(111) do
--   --   p('x', x)
--   -- end
--   -- p(await(defer(200)))
-- end)

-- async(function()
--   p(await(defer(300)))

--   -- p('before')
--   -- for y in await(defer_iter(222)) do
--   --   p('y', y)
--   --   -- for z in await(defer_iter2(20)) do
--   --   --   p('z', z)
--   --   -- end
--   -- end
--   -- p(await(x()))
--   -- local a, b = await.all({ defer(600), defer(300) }, first)
--   -- p(a)
--   -- p(b)
--   -- p('after')
-- end, function()
--   p('AFTER AFTER')
-- end)()

return {}
