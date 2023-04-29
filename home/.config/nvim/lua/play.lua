-- local a = require('meta-local.async')
-- local Path = require('plenary.path')
-- local uv = vim.loop

local function p(...)
  print(vim.inspect(...))
end

-- local function timeout(ms, callback)
--   callback(ms, 'yey')
-- end
-- local timer = a.wrap(timeout)

-- local atimer = function(ms)
--   return a.sync(function()
--     return a.wait(timer(ms))
--   end)
-- end

-- local main = a.sync(function()
--   local ti, b = a.wait_all({ timer(12), atimer(10) })
--   p('eu eimm')
--   p(ti)
--   p('top')
--   p(b)
--   p('toppp')
--   -- local tid = a.wait(atimeout(1234))
--   -- p('top')
--   -- p(tid)
--   -- p('bottom')
--   -- p(a.wait_all({ timer(100), atimeout(100) }))
-- end)

-- main()
p('ok')
p('hh')

-- local function asyncfn(ms, callback)
--   a.sync(function()
--     callback(a.wait(timer(10)))
--   end)()
-- end

-- asyncfn(300, function(b)
--   p(b)
-- end)

-- local pickers = require('telescope.pickers')
-- local finders = require('telescope.finders')
-- local conf = require('telescope.config').values
-- local themes = require('telescope.themes')
-- local actions = require('telescope.actions')
-- local action_state = require('telescope.actions.state')

-- local function get_connections()
--   return {
--     {
--       selected = true,
--       id = '123123213',
--       scheme = 'distant',
--       host = 'fabs.sb.facebook.com',
--       port = '8082',
--     },
--     {
--       selected = false,
--       id = '0000',
--       scheme = 'distant',
--       host = '123123.od.facebook.com',
--       port = '8011',
--     },
--     {
--       new_connection = true,
--       label = 'Connect to a new server using `dev connect`',
--     },
--   }
-- end

-- local colors = function(opts)
--   opts = opts or {}
--   pickers
--     .new(opts, {
--       prompt_title = 'Distant connections',
--       finder = finders.new_table({
--         results = get_connections(),
--         entry_maker = function(entry)
--           local label = entry.label and entry.label
--             or string.format('%s:%s id:%s', entry.host, entry.port, entry.id)
--           return {
--             value = entry,
--             display = label,
--             ordinal = label,
--           }
--         end,
--       }),
--       sorter = conf.generic_sorter(opts),
--       attach_mappings = function(prompt_bufnr)
--         actions.select_default:replace(function()
--           actions.close(prompt_bufnr)
--           local entry = action_state.get_selected_entry()
--           if entry.value.selected then
--             print('You were already using this connection, you are good to go!')
--             return
--           end
--           if entry.value.new_connection then
--             -- call terminal with dev connect
--             return
--           end
--           -- SWITCH CONNECTION
--         end)
--         return true
--       end,
--     })
--     :find()
-- end

-- colors(themes.get_dropdown({}))
--
return {}
