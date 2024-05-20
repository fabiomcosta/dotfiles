local utils = require('utils')

local M = {
  default_config = {
    directory = nil,
  },
}

local setup_config = function(config)
  vim.validate({ config = { config, 'table', true } })
  config =
      vim.tbl_deep_extend('force', vim.deepcopy(M.default_config), config or {})
  vim.validate({
    directory = { config.directory, 'string' },
  })
  M.config = config
end

-- from mini.session
local is_something_shown = function()
  -- Don't autoread session if Neovim is opened to show something. That is
  -- when at least one of the following is true:
  -- - Current buffer has any lines (something opened explicitly).
  -- NOTE: Usage of `line2byte(line('$') + 1) > 0` seemed to be fine, but it
  -- doesn't work if some automated changed was made to buffer while leaving it
  -- empty (returns 2 instead of -1). This was also the reason of not being
  -- able to test with child Neovim process from 'tests/helpers'.
  local lines = vim.api.nvim_buf_get_lines(0, 0, -1, true)
  if #lines > 1 or (#lines == 1 and lines[1]:len() > 0) then
    return true
  end

  -- - Several buffers are listed (like session with placeholder buffers). That
  --   means unlisted buffers (like from `nvim-tree`) don't affect decision.
  local listed_buffers = vim.tbl_filter(function(buf_id)
    return vim.fn.buflisted(buf_id) == 1
  end, vim.api.nvim_list_bufs())
  if #listed_buffers > 1 then
    return true
  end

  -- - There are files in arguments (like `nvim foo.txt` with new file).
  if vim.fn.argc() > 0 then
    return true
  end

  return false
end

local get_session_name = function()
  local name, _ = string.gsub(vim.fn.resolve(vim.loop.cwd()), '/', 'zZz')
  return name
end

local get_session_path = function(session_name)
  return utils.joinpath(M.config.directory, session_name)
end

local read = function()
  local session_path = get_session_path(get_session_name())
  vim.cmd(('silent! source %s'):format(vim.fn.fnameescape(session_path)))
  -- vim.notify(('Loaded session %s'):format(session_path))
end

local write = function()
  local session_path = get_session_path(get_session_name())
  vim.cmd(('mksession! %s'):format(vim.fn.fnameescape(session_path)))
  -- vim.notify(('Saved session %s'):format(session_path))
end

local create_autocommands = function()
  local loaded = false
  local _read = function()
    if not is_something_shown() then
      read()
      loaded = true
    end
  end
  local _write = function()
    if not loaded then
      return
    end
    write()
  end
  local augroup = vim.api.nvim_create_augroup('MicroSessions', {})
  vim.api.nvim_create_autocmd('VimEnter', {
    group = augroup,
    nested = true,
    once = true,
    desc = 'Autoread session',
    callback = _read,
  })
  vim.api.nvim_create_autocmd('VimLeavePre', {
    group = augroup,
    desc = 'Autowrite session when leaving Vim',
    callback = _write,
  })
  vim.api.nvim_create_autocmd('BufEnter', {
    group = augroup,
    desc = 'Autowrite session when opening a new buffer',
    callback = _write,
  })
end

return {
  read = read,
  write = write,
  setup = function(config)
    setup_config(config)
    create_autocommands()
  end,
}
