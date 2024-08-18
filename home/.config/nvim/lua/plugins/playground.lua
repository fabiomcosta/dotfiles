---@diagnostic disable

local function p(...)
  print(unpack(vim.tbl_map(vim.inspect, { ... })))
end

local pa = require('plenary.async')
local co = coroutine

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

-- Only lets this method be called once.
-- the followingi  calls ignore the wrapped function and simply return nil.
local once = function(func)
  local called = nil
  return function(...)
    if called == nil then
      called = true
      return func(...)
    end
  end
end

function create_callable(func, props)
  return setmetatable(props or {}, {
    __call = function(self, ...)
      return func(...)
    end,
  })
end

local function identity(a1)
  return a1
end

local function first(a1)
  return a1[1]
end

local function is_callable(fn)
  return type(fn) == 'function'
    or (type(fn) == 'table' and type(getmetatable(fn)['__call']) == 'function')
end

local function assert_callable(func)
  assert(
    is_callable(func),
    'type error :: expected func or table with __call property'
  )
end

local function w(func, name)
  return create_callable(func, { name = name })
end

--#################### END UTILS ####################

local await = create_callable(function(defer)
  assert_callable(defer)
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
local wrap = create_callable(function(func)
  return function(...)
    local params = { ... }
    return function(step)
      table.insert(params, step)
      return func(unpack(params))
    end
  end
end)

local thunk_factory = wrap(pong)
local async = function(func)
  return function(...)
    -- This check allows the async function to be the root async function,
    -- else it would never run.
    -- TODO this needs to improve because we need to make sure this is actually
    -- our coroutine that is running, not any coroutine.
    local params = { ... }
    local async_func = function()
      return func(unpack(params))
    end
    if not coroutine.running() then
      return pong(async_func)
    end
    return thunk_factory(async_func)
  end
end

-- TODO add options, like timeout that will throw or maybe that will force
-- the iterator to stop.
wrap.iter = function(func)
  local thunk_factory = wrap(func)
  return function(...)
    local thunk = once(thunk_factory(...))
    return function()
      return await(thunk)
    end
  end
end

local a = {
  sync = async,
  wait = await,
  wrap = wrap,
}

function defer_iter_cb(timeout, done)
  -- p('PARAMS1!', timeout, done)
  vim.defer_fn(function()
    done(timeout)
  end, timeout)
  vim.defer_fn(function()
    done(nil)
  end, 600)
  vim.defer_fn(function()
    done(300)
  end, 300)
end

function defer_iter_cb2(timeout, done)
  -- p('PARAMS2!', timeout)
  vim.defer_fn(function()
    done(timeout)
  end, timeout)
  vim.defer_fn(function()
    done(nil)
  end, 600)
  vim.defer_fn(function()
    done(300)
  end, 300)
end

-- TODO: play with error handling

local defer = wrap(function(timeout, done)
  vim.defer_fn(function()
    done(timeout, 900)
  end, timeout)
end)

local defer_iter = wrap.iter(defer_iter_cb)
local defer_iter2 = wrap.iter(defer_iter_cb2)

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

local x = async(function()
  -- p(await(defer(300)))
  for x in defer_iter2(111) do
    p('x', x)
  end
  -- p(await(defer(200)))
end)

-- async(function()
--   p('before')
--   for y in defer_iter(222) do
--     p('y', y)
--     -- await(x())
--     -- for z in defer_iter(20) do
--     --   p('z', z)
--     -- end
--   end
--   -- local a, b = await.all({ defer(600), defer(300) }, first)
--   -- p(a)
--   -- p(b)
--   p('after')
-- end)()
return {}
