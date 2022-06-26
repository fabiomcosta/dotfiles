local pickers = require("telescope.pickers")
local finders = require("telescope.finders")
local conf = require("telescope.config").values
local actions = require("telescope.actions")
local action_state = require("telescope.actions.state")
local themes = require("telescope.themes")
local previewers = require("telescope.previewers")
local Job = require("plenary.job")

local function map(tbl, f)
  local t = {}
  for k, v in pairs(tbl) do
    t[k] = f(v, k)
  end
  return t
end

local function split(inputstr, pattern)
  local t = {}
  local acc = 0
  while true do
    local start_index, end_index = string.find(inputstr, pattern, acc)
    if start_index == nil then
      -- no more patterns found, add last value and leave
      table.insert(t, string.sub(inputstr, acc, string.len(inputstr)))
      break
    end
    table.insert(t, string.sub(inputstr, acc, start_index - 1))
    acc = end_index + 1
  end
  return t
end

local NIL = {}
local function memoize(fn, cache_key_gen)
  cache_key_gen = cache_key_gen or function(a1)
    return a1
  end
  local cache = {}
  return function(...)
    local arg = { ... }
    local cache_key = cache_key_gen(unpack(arg))
    if cache_key == nil then
      return error("Cache key can't be nil.")
    end
    if cache[cache_key] == NIL then
      return nil
    end
    if cache[cache_key] ~= nil then
      return cache[cache_key]
    end
    local result = fn(unpack(arg))
    if result == nil then
      cache[cache_key] = NIL
    else
      cache[cache_key] = result
    end
    return result
  end
end

local function get_os_command_output(cmd, opts)
  opts = opts or {}
  local command = table.remove(cmd, 1)
  local stderr = {}
  local stdout, ret = Job:new({
    command = command,
    args = cmd,
    cwd = opts.cwd,
    on_stderr = function(_, data)
      table.insert(stderr, data)
    end,
  }):sync(opts.timeout)
  return stdout, ret, stderr
end

local function system(cmd, opts)
  local stdout, exit_code, stderr = get_os_command_output(cmd, opts)
  if exit_code ~= 0 then
    return error('stderr: ' .. stderr .. '\nstdout: ' .. stdout)
  end
  return vim.trim(stdout[1] or '')
end

local function is_system_success(cmd, opts)
  local _, exit_code = get_os_command_output(cmd, opts)
  return exit_code == 0
end

local is_hg_repo_in_cwd = memoize(function(cwd)
  return is_system_success({ 'hg', 'root' }, { cwd = cwd })
end)

local function is_hg_repo()
  return is_hg_repo_in_cwd(vim.loop.cwd())
end

local function git_get_repo_root_in_cwd(cwd)
  return system({ 'git', 'rev-parse', '--show-toplevel' }, { cwd = cwd })
end

local function hg_get_repo_root_in_cwd(cwd)
  return system({ 'hg', 'root' }, { cwd = cwd })
end

local get_repo_root_in_cwd = memoize(function(cwd)
  return is_hg_repo_in_cwd(cwd) and hg_get_repo_root_in_cwd(cwd) or git_get_repo_root_in_cwd(cwd)
end)

local function get_repo_root()
  return get_repo_root_in_cwd(vim.loop.cwd())
end

local function get_project_id()
  local project = vim.split(system({ 'arc', 'get-config', 'project_id' }), ':')
  return vim.trim(project[2])
end

local function git_get_commit_hash_from_diff_id(diff_id)
  -- Looking only till 3 months so we dont keep looking for too long.
  -- 3 months should be enough??
  return system({ 'git', 'log', '--all', '--since="3 months ago"', '-1', '--format=%H', '--fixed-strings', '--grep',
    diff_id })
end

local function git_get_branch_name_from_commit_hash(commit_hash)
  return vim.split(
    system({ 'git', 'name-rev', '--name-only', commit_hash }),
    '~'
  )[1]
end

local function git_is_diff_from_current_repo(diff_id)
  return git_get_commit_hash_from_diff_id(diff_id) ~= ''
end

local function hg_is_diff_from_current_repo(diff_id)
  return is_system_success({ 'hg', 'log', '-T', '" "', '-r', diff_id })
end

local is_diff_from_current_repo = memoize(function(diff_id)
  if is_hg_repo() then
    return hg_is_diff_from_current_repo(diff_id)
  else
    return git_is_diff_from_current_repo(diff_id)
  end
end)

local function git_get_diff_files_finder(opts)
  local commit_hash = git_get_commit_hash_from_diff_id(opts.diff.id)
  return finders.new_oneshot_job({
    'git',
    'show',
    '--name-only',
    '--diff-filter=AM',
    '--format=',
    commit_hash,
  }, opts)
end

local function hg_get_diff_files_finder(opts)
  return finders.new_oneshot_job({
    'hg',
    'status',
    '--no-status',
    '--color=never',
    '--added',
    '--modified',
    '--change',
    opts.diff.id,
  }, opts)
end

local function get_diff_files_finder(opts)
  local repo_root = get_repo_root()
  opts.entry_maker = opts.entry_maker or function(entry)
    return {
      value = entry,
      display = entry,
      ordinal = entry,
      path = repo_root .. '/' .. entry
    }
  end
  if is_hg_repo() then
    return hg_get_diff_files_finder(opts)
  else
    return git_get_diff_files_finder(opts)
  end
end

local function git_checkout_diff(diff_id)
  local commit_hash = git_get_commit_hash_from_diff_id(diff_id)
  local branch_name = git_get_branch_name_from_commit_hash(commit_hash)
  system({ 'git', 'checkout', branch_name }, { timeout = 20000 })
end

local function hg_checkout_diff(diff_id)
  system({ 'hg', 'checkout', diff_id }, { timeout = 20000 })
end

local function checkout_diff(diff_id)
  if is_hg_repo() then
    hg_checkout_diff(diff_id)
  else
    git_checkout_diff(diff_id)
  end
end

local function parse_diff_entry(diff_entry)
  local diff_id = string.match(diff_entry, 'D%d+')
  if diff_id == nil then
    return nil
  end
  local diff_data = map(split(diff_entry, 'D%d+'), vim.trim)
  return {
    id = diff_id,
    status = string.lower(diff_data[1]),
    title = diff_data[2],
  }
end

local function get_own_diffs_finder(opts)
  opts.entry_maker = opts.entry_maker or function(entry)
    local diff_entry = vim.trim(entry)
    local diff = parse_diff_entry(diff_entry)
    if diff == nil then
      return nil
    end
    if not is_diff_from_current_repo(diff.id) then
      return nil
    end
    return {
      value = entry,
      display = entry,
      ordinal = entry,
      diff = diff,
    }
  end
  return finders.new_oneshot_job({ 'jf', 'list' }, opts)
end

local function get_file_diff_previewer(opts)
  if is_hg_repo() then
    return previewers.new_termopen_previewer({
      get_command = function(entry)
        return { 'hg', 'log', '--page=never', '--template', '" "', '-p', '-r', opts.diff.id, entry.path }
      end
    })
  else
    return previewers.new_termopen_previewer({
      get_command = function(entry)
        local commit_hash = git_get_commit_hash_from_diff_id(opts.diff.id)
        return { 'git', '--no-pager', 'show', '-p', '--format=', commit_hash, '--', entry.path }
      end
    })
  end
end

local function diff_file_picker(opts)
  pickers.new(opts, {
    prompt_title = "Files on [" .. opts.diff.id .. "] " .. opts.diff.title,
    finder = get_diff_files_finder(opts),
    sorter = conf.generic_sorter(opts),
    previewer = get_file_diff_previewer(opts),
  }):find()
end

local function diff_picker(opts)
  opts = themes.get_dropdown(opts or {})
  pickers.new(opts, {
    prompt_title = 'Your ' .. get_project_id() .. ' diffs',
    finder = get_own_diffs_finder(opts),
    sorter = conf.generic_sorter(opts),
    attach_mappings = function(prompt_bufnr)
      actions.select_default:replace(function()
        actions.close(prompt_bufnr)
        local selection = action_state.get_selected_entry()
        if opts.checkout then
          checkout_diff(selection.diff.id)
        end
        diff_file_picker(selection)
      end)
      return true
    end,
  }):find()
end

return {
  diff_picker = diff_picker
}
