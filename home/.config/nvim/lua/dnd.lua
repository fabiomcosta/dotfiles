-- Simple pattern that looks for an absolute path
-- local PATH_PATTERN = '^%/?[%w%._%-%/]+$'
local FILEPROXY_URL = 'http://localhost:8092/fileproxy'
-- The dnd handlers are only going to work when the current buffer
-- matches this pattern.
local PATTERN = '*.commit.hg.txt'
local _is_focused = true
local _last_cursor_pos = nil

local function url_encode(str)
  str = str:gsub('([^%w%-_%.%~])', function(c)
    return string.format('%%%02X', string.byte(c))
  end)
  return str
end

local function url_encode_path(path)
  local paths = vim.split(path, '/')
  paths = vim.tbl_map(url_encode, paths)
  return vim.fn.join(paths, '/')
end

-- same as vim.fn.tempname but makes sure that the tmp file is the same
-- as the one provided.
local function tempname_for(path)
  local tmp_path = vim.fn.tempname()
  return vim.fs.joinpath(vim.fs.dirname(tmp_path), vim.fs.basename(path))
end

local function is_ssh_session()
  return vim.env.SSH_CLIENT ~= nil
end

-- Download file from the local fileproxy
local function download_from_fileproxy(file_path, tmp_path, callback)
  vim.system(
    {
      'curl',
      '-s',
      '-w',
      '%{http_code}',
      '-o',
      tmp_path,
      FILEPROXY_URL .. url_encode_path(file_path),
    },
    {},
    vim.schedule_wrap(function(obj)
      if obj.code ~= 0 or obj.stdout ~= '200' then
        return vim.notify(
          string.format(
            [[Could not download "%s" from local file proxy. HTTP error %s.]],
            vim.fs.basename(file_path),
            obj.stdout
          ),
          vim.log.levels.ERROR
        )
      end
      callback(obj)
    end)
  )
end

local function px_upload(file_path, callback)
  local stderr_data
  local px_proc
  px_proc = vim.system(
    { 'px', 'upload', file_path },
    {
      timeout = 12000,
      text = true,
      stdin = true,
      stderr = vim.schedule_wrap(function(err, data)
        -- When first running px it asks the user to paste the token
        -- from a provided URL, this awkward prompts the user to that
        -- and writes it back to the px process.
        if err == nil and data ~= nil and stderr_data ~= data then
          stderr_data = data
          local token = vim.fn.input(data)
          px_proc:write(token .. '\n')
        end
      end),
    },
    vim.schedule_wrap(function(obj)
      if obj.code ~= 0 then
        if obj.code == 124 and not is_ssh_session() then
          return vim.notify(
            string.format(
              [[Uploading "%s" to pixelcloud timed out. You likely need to connect to the VPN.]],
              vim.fs.basename(file_path)
            ),
            vim.log.levels.ERROR
          )
        end
        return vim.notify(
          string.format(
            [[Could not upload "%s" to pixelcloud.]],
            vim.fs.basename(file_path)
          ),
          vim.log.levels.ERROR
        )
      end
      callback(obj)
    end)
  )
end

local function focus_events(focus_gained_callback, focus_lost_callback, config)
  -- When neovim is running through SSH the focus events don't work similarly
  -- to how they work localy.
  -- Losing focus on the current window to another window on the client won't
  -- trigger a FocusLost event, only when changing between tmux windows.
  -- To fix that, chatgpt suggested using this workround which seems to work
  -- with its own limitations.
  if is_ssh_session() then
    -- milliseconds for "lost focus" detection
    -- CursorHold triggers after this
    vim.o.updatetime = 1500
    local is_focused = true
    local function simulate_focus_gained()
      if not is_focused then
        is_focused = true
        vim.schedule(focus_gained_callback)
      end
    end
    local function simulate_focus_lost()
      if is_focused then
        is_focused = false
        vim.schedule(focus_lost_callback)
      end
    end
    vim.api.nvim_create_autocmd(
      { 'CursorMoved', 'CursorMovedI' },
      vim.tbl_deep_extend('force', config, {
        callback = simulate_focus_gained,
      })
    )
    vim.api.nvim_create_autocmd(
      'CursorHold',
      vim.tbl_deep_extend('force', config, {
        callback = simulate_focus_lost,
      })
    )
  else
    vim.api.nvim_create_autocmd(
      'FocusGained',
      vim.tbl_deep_extend('force', config, {
        callback = function()
          focus_gained_callback()
        end,
      })
    )
    vim.api.nvim_create_autocmd(
      'FocusLost',
      vim.tbl_deep_extend('force', config, {
        callback = function()
          focus_lost_callback()
        end,
      })
    )
  end
end

-- Inferring cursor size from neovim node.
-- This is not accurate for all users, but should work for most.
-- GUI users might want to change this to use vim.opt.guicursor:get()
local function get_cursor_size()
  local mode = vim.fn.mode()
  -- normal and visual modes have the ticker cursor
  if mode == 'n' or mode == 'v' then
    return 1
  end
  return 0
end

local function split_file_path(file_path)
  -- When dnd multiple files, they are separated by a space, and if there are
  -- spaces on the filepath itself they are back-escaped.
  -- ex: /with\\ space/file.php /another.php
  -- So this is replacing all spaces that are part of the files into a `}*{`
  -- (could be anything that is "unique enough")
  file_path = file_path:gsub('\\ ', '}*{')
  -- Now we can safely split the paths using space
  local file_paths = vim.split(file_path, ' ')
  -- And put the spaces back
  return vim.tbl_map(function(path)
    -- Also remove any other backspaces that are added for other special
    -- charaters like "(" and ")".
    return path:gsub('[}][*][{]', ' '):gsub('\\', '')
  end, file_paths)
end

local function is_likely_dnd(file_paths)
  for _, file_path in ipairs(file_paths) do
    if #file_path <= 1 then
      return false
    end
    if file_path:find('://') ~= nil then
      return false
    end
  end
  return true
end

local function replace_column_range(buf, line, start_col, end_col, replacement)
  local text = vim.api.nvim_buf_get_lines(buf, line, line + 1, false)[1]
  if not text then
    return
  end
  local new_text = text:sub(1, start_col)
      .. replacement
      .. text:sub(end_col + 1)
  vim.api.nvim_buf_set_lines(buf, line, line + 1, false, { new_text })
end

local function handle_drop()
  -- In general the user needs to blur/focusout nvim in order to be able
  -- to drag-n-drop a file, and when dropping it the text is first updated
  -- before the FocusGained.
  if _is_focused then
    return
  end

  local line = vim.api.nvim_get_current_line()
  local first_slash_index = line:find('/')
  if first_slash_index == nil then
    -- Ignore as chances are there was no file drag-n-drop event
    return
  end

  local win_id = vim.api.nvim_get_current_win()
  local cursor_pos = vim.api.nvim_win_get_cursor(win_id)

  local initial_col
  if _last_cursor_pos ~= nil then
    initial_col = _last_cursor_pos[2] + get_cursor_size() + 1
    vim.notify(string.format('%s %s', cursor_pos[2], initial_col))
  else
    initial_col = first_slash_index
  end

  local cursor_row, cursor_col = unpack(cursor_pos)
  local file_path =
      vim.trim(line:sub(initial_col, cursor_col + get_cursor_size()))
  local file_paths = split_file_path(file_path)

  if not is_likely_dnd(file_paths) then
    -- Ignore as chances are there was no file drag-n-drop event
    return
  end

  -- TODO: simple path validation
  vim.notify(('Processing %s...'):format(vim.fn.join(file_paths, ', ')))

  -- if this is an ssh session, we can't check if the file exists, because
  -- it is local to the client and not the server.
  if not is_ssh_session() then
    for _, file_path in ipairs(file_paths) do
      local stats = vim.uv.fs_stat(file_path)
      if stats == nil then
        vim.notify(
          string.format([["%s" doesn't exists.]], file_path),
          vim.log.levels.ERROR
        )
      end
    end
  end

  local buf_id = vim.api.nvim_get_current_buf()
  -- Remove the pasted file paths from the buffer
  replace_column_range(
    buf_id,
    cursor_row - 1,
    initial_col - 1,
    cursor_col + get_cursor_size(),
    ''
  )

  -- TODO an inline UI wi/Users/fabs/local.txtth "Uploading {file_path}..." message
  -- TODO it would be nice to keep the same order as the pasted files
  -- currently the first file to upload is pasted in the buffer.
  for i, file_path in ipairs(file_paths) do
    local tmp_path = tempname_for(file_path)
    download_from_fileproxy(file_path, tmp_path, function(obj)
      px_upload(tmp_path, function(obj)
        local px_url = vim.trim(obj.stdout)
        replace_column_range(
          buf_id,
          cursor_row - 1,
          initial_col - 1,
          initial_col - 1,
          ' ' .. px_url
        )
      end)
    end)
  end
end

local M = {}

function M.disable()
  return vim.api.nvim_create_augroup('meta_dnd', { clear = true })
end

function M.setup()
  local augroup = M.disable()
  vim.api.nvim_create_autocmd({ 'TextChangedI', 'TextChanged' }, {
    pattern = PATTERN,
    group = augroup,
    callback = handle_drop,
  })
  focus_events(function()
    _is_focused = true
  end, function()
    _is_focused = false
    local win_id = vim.api.nvim_get_current_win()
    _last_cursor_pos = vim.api.nvim_win_get_cursor(win_id)
  end, { pattern = PATTERN, group = augroup })
end

return M
