local pickers = require('telescope.pickers')
local conf = require('telescope.config').values
local themes = require('telescope.themes')
local actions = require('telescope.actions')
local action_state = require('telescope.actions.state')
local finders = require('telescope.finders')

local distant = require('distant')
local distant_command = require('distant.command')
local distant_state = require('distant.state')
local distant_utils = require('distant.utils')
local distant_install = require('distant.cli.install')
local distant_cmd = require('distant.cli.cmd')

local a = require('meta-local.async')

local read_dir = a.wrap(distant.fn.read_dir)

local function p(...)
  print(vim.inspect(...))
end

-- LOL
local function stringtoboolean(value)
  return ({ ['true'] = true, ['false'] = false })[value]
end

local function booleantonumber(value)
  return value and 1 or 0
end

local stream_marker = {
  find = function(text, tag_name)
    return text:find(string.format('<<%s>>', tag_name))
  end,
  remove = function(text, tag_name)
    return text:gsub(string.format('<<%s>>', tag_name), '')
  end,
}

-- vim.tbl_map doesn't provide the key to the map function :/
local function tbl_map(table, map_fn)
  local mapped_table = {}
  for key, value in pairs(table) do
    local new_value, new_key = map_fn(value, key)
    mapped_table[new_key or key] = new_value
  end
  return mapped_table
end

local function get_connections(cb)
  -- If there is no manager available we won't be able to query for the
  -- active connections or select any.
  -- Let's just present the "new connection" option.
  -- This generally happens the first time people run this command right
  -- after opening neovim.
  if not distant_state.manager then
    return cb({})
  end

  local distant_bin_path = distant_install.path()
  local list_cmd = distant_cmd.manager
      .list()
      :set_from_tbl(distant_state.manager.config.network)
      :as_list()
  table.insert(list_cmd, 1, distant_bin_path)

  local connections = {}
  distant_utils.job_start(list_cmd, {
    on_stdout_line = function(connection)
      local fields = vim.split(connection, '|', { trimempty = true })
      fields = vim.tbl_map(vim.trim, fields)
      if #fields <= 1 or fields[1] == 'selected' then
        return
      end
      table.insert(connections, {
        selected = stringtoboolean(fields[1]),
        id = fields[2],
        scheme = fields[3],
        host = fields[4],
        port = fields[5],
      })
    end,
    on_success = function()
      -- sorts the connections so that the currently selected connection is on
      -- the top of the list.
      connections = vim.fn.sort(connections, function(a, b)
        return booleantonumber(b.selected) - booleantonumber(a.selected)
      end)
      table.insert(connections, {
        new_connection = true,
        label = 'Connect to a new server using `dev connect`',
      })
      cb(connections)
    end,
  })
end

local function get_available_cwds(remote_username, cb)
  -- we can do a smart list of project paths
  -- as well as list the ones that the user might have listed
  -- on their config, giving priority to the ones they listed.
  a.sync(function()
    local dev_dirs, od_dirs = a.wait_all({
      read_dir({
        path = '/data/users/' .. remote_username,
        depth = 1,
        absolute = true,
      }),
      read_dir({
        path = '/data/sandcastle/boxes/',
        depth = 1,
        absolute = true,
      }),
    })
    -- There is not much value in handling exceptions here.
    -- But if we don't have at least one entry to show we'll show an error.

    local cwd = distant_state.settings.cwd or {}
    if type(cwd) == 'string' then
      cwd = { default = cwd }
    end

    local entries = vim.tbl_values(tbl_map(cwd, function(path, alias)
      return {
        label = alias,
        path = path,
        is_user_config = true,
      }
    end))

    vim.list_extend(entries, (dev_dirs[2] or {}).entries or {})
    vim.list_extend(entries, (od_dirs[2] or {}).entries or {})

    cb(entries)
  end)()
end

local function get_dev_connect_cmd(cb)
  local filename = debug.getinfo(1).source:sub(2)
  local dirname = vim.fn.fnamemodify(filename, ':p:h')
  local setup_script_path = dirname .. '/distant-setup.sh'

  local homedir = vim.loop.os_homedir()
  local distant_bin_path = distant_install.path()
  local remote_distant_bin_path = '~'
      .. string.sub(distant_bin_path, #homedir + 1)

  local get_distant_version_cmd = ([[%s --version 2>&1 | cut -d ' ' -f 2-]]):format(
    distant_bin_path
  )
  get_connections(function(connections)
    local cons = tbl_map(
      vim.tbl_filter(function(connection)
        return connection.scheme == 'distant'
      end, connections),
      function(connection)
        return string.format('%s#%s', connection.id, connection.host)
      end
    )
    cb(
      ([[dev connect --no-release-prompt --skip-waiting-dotfiles-sync --skip-homedir -- 'bash -s' < %s "$(%s)" '%s' '%s']])
      :format(
        setup_script_path,
        get_distant_version_cmd,
        remote_distant_bin_path,
        table.concat(cons, '/')
      )
    )
  end)
end

local function connect_to_new_server(cb)
  local buffer_id = vim.api.nvim_create_buf(false, true)
  local max_width = vim.o.columns
  local max_height = vim.o.lines - vim.o.cmdheight - 1
  -- local gutter = 10

  local width = 120
  local height = 26

  local win_id = vim.api.nvim_open_win(buffer_id, true, {
    relative = 'editor',
    border = 'single',
    width = width,                   --vim.o.columns - (gutter * 2),
    height = height,                 --max_height - gutter,
    row = (max_height - height) / 2, -- (gutter / 2) - 1,
    col = (max_width - width) / 2,   -- gutter,
  })

  local entered_insert_mode = false
  local distant_address = nil
  local connection_id = nil
  get_dev_connect_cmd(function(cmd)
    vim.fn.termopen(cmd, {
      on_stdout = function(_, data)
        for _, text in ipairs(data) do
          if not entered_insert_mode and text:find('Fuzzy select') then
            -- It's likely time to ask for what server they would
            -- like to connect to.
            -- NOTE: I tried to do this on TermOpen, but that didn't work.
            vim.api.nvim_win_call(win_id, function()
              vim.cmd('startinsert')
            end)
            entered_insert_mode = true
          elseif stream_marker.find(text, 'CONNECTION_ID') then
            connection_id =
                vim.trim(stream_marker.remove(text, 'CONNECTION_ID'))
          elseif stream_marker.find(text, 'DISTANT_ADDRESS') then
            distant_address =
                vim.trim(stream_marker.remove(text, 'DISTANT_ADDRESS'))
          elseif stream_marker.find(text, 'SUCCESS') then
            vim.api.nvim_win_close(win_id, true)
          end
        end
      end,
      on_stderr = function(_, data)
        vim.notify(table.concat(data, '\n'), vim.log.levels.ERROR)
      end,
      on_exit = function()
        if connection_id then
          distant_state.manager:select(
            { connection = connection_id },
            function()
              vim.notify(
                string.format(
                  'There was already a connection to the server you just connected and it is now being used. connection:%s',
                  connection_id
                )
              )
            end
          )
          return
        elseif distant_address then
          distant.editor.connect(
            { destination = distant_address },
            function(err)
              if err then
                error(tostring(err) or 'Connect failed without cause')
                return
              end
              vim.notify('Connected to ' .. distant_address)
              cb()
            end
          )
          return
        end
        vim.notify(
          'Could not connect to a distant server.',
          vim.log.levels.ERROR
        )
      end,
    })
  end)
end

local function select_cwd(opts)
  opts = themes.get_dropdown(opts)
  distant.fn.spawn_wait(
    { cmd = 'id -u -n' },
    vim.schedule_wrap(function(err, proccess)
      if err then
        vim.notify(err, vim.log.levels.ERROR)
        return
      end
      local remote_username = vim.trim(string.char(unpack(proccess.stdout)))
      -- TODO ideally this would be a part of an async finder, but I
      -- couldn't build a reliable one.
      get_available_cwds(remote_username, function(roots)
        pickers
            .new(opts, {
              prompt_title = 'Distant: select your project root',
              finder = finders.new_table({
                results = roots,
                entry_maker = function(entry)
                  local filename = vim.fn.fnamemodify(entry.path, ':t')
                  if
                      not entry.is_user_config
                      and (
                        entry.file_type ~= 'dir' or vim.startswith(filename, '.')
                      )
                  then
                    return nil
                  end
                  local label = entry.label or filename
                  return {
                    value = entry,
                    display = label .. ' at ' .. entry.path,
                    ordinal = label,
                  }
                end,
              }),
              sorter = conf.generic_sorter(opts),
              attach_mappings = function(prompt_bufnr)
                actions.select_default:replace(function()
                  actions.close(prompt_bufnr)
                  local entry = action_state.get_selected_entry()
                  distant_command.cwd(entry.value.path)
                end)
                return true
              end,
            })
            :find()
      end)
    end)
  )
end

local function select_distant_connection(opts)
  opts = themes.get_dropdown(opts)
  -- TODO ideally this would be a part of an async finder, but I
  -- couldn't build a reliable one.
  get_connections(function(connections)
    -- if there are no active connections, there is no point in showing
    -- the connection picker, so we try to connect directly.
    if vim.tbl_isempty(connections) then
      connect_to_new_server(function()
        select_cwd()
      end)
      return
    end
    pickers
        .new(opts, {
          prompt_title = 'Distant: select a connection, or create a new one',
          finder = finders.new_table({
            results = connections,
            entry_maker = function(entry)
              local current_label = entry.selected and ' (current)' or ''
              local label = entry.label and entry.label
                  or string.format(
                    '%s://%s:%s id:%s%s',
                    entry.scheme,
                    entry.host,
                    entry.port,
                    entry.id,
                    current_label
                  )
              return {
                value = entry,
                display = label,
                ordinal = label,
              }
            end,
          }),
          sorter = conf.generic_sorter(opts),
          attach_mappings = function(prompt_bufnr)
            actions.select_default:replace(function()
              actions.close(prompt_bufnr)
              local entry = action_state.get_selected_entry()
              if entry.value.selected then
                vim.notify(
                  'You were already using this connection, you are good to go!'
                )
                return
              end
              if entry.value.new_connection then
                connect_to_new_server(function()
                  select_cwd()
                end)
                return
              end
              distant_state.manager:select(
                { connection = entry.value.id },
                function()
                  vim.notify(
                    string.format(
                      'Distant is now using "%s" to communicate to the server.',
                      entry.display
                    )
                  )
                end
              )
            end)
            return true
          end,
        })
        :find()
  end)
end

return {
  select_connection = select_distant_connection,
  connect_to_new_server = connect_to_new_server,
  select_cwd = select_cwd,
}
