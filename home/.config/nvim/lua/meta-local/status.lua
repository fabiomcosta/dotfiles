local distant_state = require('distant.state')

local status = {}

function status.get(config)
  if not distant_state.client then
    return ''
  end
  local text = {}
  if config.options.show_server_address ~= false then
    -- TODO once we start managing multiple connections inside
    -- distant.nvim this will likely change.
    -- We'll need to get the currently active connection.
    -- Hopefuly something like:
    -- distant_state.manager:get_active_connect().destination.address
    local connections = vim.tbl_values(distant_state.manager.connections)
    -- distant://:nnn@devvm5089.frc0.facebook.com:8082
    local address = connections[1].destination:match('@([%w.]+):%w+$')
    address = address:gsub('.facebook.com$', '')
    address = address:gsub('.fbinfra.net$', '')
    table.insert(text, address)
  end
  -- this is still not supported on distant.nvim
  -- if config.options.show_project_root ~= false then
  -- end
  return ' ' .. table.concat(text, ':') -- f0c2
end

return status
