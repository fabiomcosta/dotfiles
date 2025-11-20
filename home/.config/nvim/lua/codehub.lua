local function table_get_from_end(table_instance, index)
  return table_instance[#table_instance + 1 - index]
end

local function split(inputstr, sep)
  if sep == nil then
    sep = '%s'
  end
  local t = {}
  for str in string.gmatch(inputstr, '([^' .. sep .. ']+)') do
    table.insert(t, str)
  end
  return t
end

local BASE_URL = 'https://www.internalfb.com/code/'

local function get_line_range(mode)
  if mode == 'n' then
    return vim.fn.line('.')
  end
  local start_line = vim.fn.line("'<")
  local end_line = vim.fn.line("'>")

  if end_line == 0 then
    return start_line
  end
  return start_line .. '-' .. end_line
end

local function get_repo_name()
  local remote_url =
      vim.fn.trim(vim.fn.system({ 'git', 'remote', 'get-url', 'origin' }))
  local urlParts = split(remote_url, '/')
  return table_get_from_end(urlParts, 2)
      .. '-'
      .. table_get_from_end(urlParts, 1)
end

local function get_url_for_git_repo(mode)
  local repo = get_repo_name()
  local git_path_prefix =
      vim.fn.trim(vim.fn.system({ 'git', 'rev-parse', '--show-prefix' }))
  local line_range = get_line_range(mode)
  local local_path =
      vim.fn.resolve(vim.fn.fnamemodify(vim.fn.expand('%'), ':~:.'))
  local url = BASE_URL
      .. repo
      .. '/'
      .. git_path_prefix
      .. local_path
      .. '?lines='
      .. line_range
  return url
end

local function get_url(mode, opts)
  local meta_cmds_status, meta_cmds = pcall(require, 'meta.cmds')
  if meta_cmds_status then
    local hg_root_path = vim.fs.root(vim.uv.cwd() or vim.fn.getcwd(), { '.hg' })
    if hg_root_path ~= nil then
      if mode == 'n' then
        return meta_cmds.get_codehub_link()
      else
        return meta_cmds.get_codehub_link(2, opts.line1, opts.line2)
      end
    end
  end
  return get_url_for_git_repo(mode)
end

local function copy_to_register(url)
  vim.fn.setreg('+', url)
  print('copied ' .. url)
end

local function copy_url(mode, opts)
  local url = get_url(mode, opts)
  copy_to_register(url)
end

local function open_or_copy_url(url)
  if vim.ui.open(url):wait().code == 0 then
    -- if open succeeded
    return true
  end
  copy_to_register(url)
  return false
end

local function open_url(mode, opts)
  local url = get_url(mode, opts)
  open_or_copy_url(url)
end

local function codehub_link_yank(opts)
  local action = opts.fargs[1]

  local mode = vim.fn.mode()                          -- detect current mode
  if mode == 'v' or mode == 'V' or mode == '\22' then -- <C-V>
    mode = 'v'
    vim.cmd([[execute "normal! \<ESC>"]])
  end

  local opts = {
    line1 = vim.fn.line("'<"),
    line2 = vim.fn.line("'>"),
  }
  if action == 'copy' then
    return copy_url(mode, opts)
  elseif action == 'open' then
    return open_url(mode, opts)
  end
  assert('copy and open are the only supported actions.')
end

vim.api.nvim_create_user_command('CodehubLinkYank', codehub_link_yank, {
  desc = 'Yank codehub link command',
  nargs = '+',
})

return {
  codehub_link_yank = codehub_link_yank,
}
