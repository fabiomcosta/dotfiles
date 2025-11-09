local FILEPROXY_URL = 'http://localhost:8092/fileproxy'
local is_focused = true
-- Simple pattern that looks for an absolute path
local path_pattern = '^%/?[%w%._%-%/]+$'

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

local function is_ssh_session()
  return vim.env.SSH_CLIENT ~= nil
end

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
  return vim.fn.join({ vim.fs.dirname(tmp_path), vim.fs.basename(path) }, '/')
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
  if is_focused then
    return
  end

  local line = vim.api.nvim_get_current_line()
  local first_slash_index = line:find('/')
  if first_slash_index == nil then
    -- Ignore as chances are there was no file drag-n-drop event
    return
  end

  local buf_id = 0
  local win_id = vim.api.nvim_get_current_win()
  local cursor_row, cursor_col = unpack(vim.api.nvim_win_get_cursor(win_id))

  local file_path = line:sub(first_slash_index, cursor_col + get_cursor_size())
  if file_path == '' then
    -- Ignore as chances are there was no file drag-n-drop event
    return
  end

  local file_paths = split_file_path(file_path)

  -- TODO: simple path validation

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

  -- Remove the pasted file paths from the buffer
  replace_column_range(
    buf_id,
    cursor_row - 1,
    first_slash_index - 1,
    cursor_col + get_cursor_size(),
    ''
  )

  vim.notify('Uploading to pixelcloud ' .. vim.inspect(file_paths))
  -- TODO an inline UI wi/Users/fabs/local.txtth "Uploading {file_path}..." message

  -- TODO it would be nice to keep the same order as the pasted files
  -- currently the first file to upload is pasted in the buffer.
  for _, file_path in ipairs(file_paths) do
    local tmp_path = tempname_for(file_path)

    vim.system(
      { 'curl', '-o', tmp_path, FILEPROXY_URL .. url_encode_path(file_path) },
      {},
      function(obj)
        if obj.code ~= 0 then
          return vim.notify(
            string.format(
              [[Could not download "%s" from proxy server.]],
              file_path
            ),
            vim.log.levels.ERROR
          )
        end
        vim.system(
          { 'px', 'upload', tmp_path },
          { text = true },
          vim.schedule_wrap(function(obj)
            local px_url = vim.trim(obj.stdout)
            replace_column_range(
              buf_id,
              cursor_row - 1,
              first_slash_index - 1,
              first_slash_index - 1,
              ' ' .. px_url
            )
          end)
        )
      end
    )
  end
end

local M = {}

function M.disable()
  return vim.api.nvim_create_augroup('meta_dnd', { clear = true })
end

function M.setup()
  local augroup = M.disable()
  vim.api.nvim_create_autocmd({ 'TextChangedI', 'TextChanged' }, {
    group = augroup,
    callback = handle_drop,
  })
  vim.api.nvim_create_autocmd('FocusGained', {
    group = augroup,
    callback = function()
      is_focused = true
    end,
  })
  vim.api.nvim_create_autocmd('FocusLost', {
    group = augroup,
    callback = function()
      is_focused = false
    end,
  })
end

return M
