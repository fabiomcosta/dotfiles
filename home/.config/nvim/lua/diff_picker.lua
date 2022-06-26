local pickers = require("telescope.pickers")
local finders = require("telescope.finders")
local conf = require("telescope.config").values
local actions = require("telescope.actions")
local action_state = require("telescope.actions.state")
local themes = require("telescope.themes")

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

local function memoize_once(fn)
  local called = false
  local cached_result = nil
  return function(...)
    local arg = { ... }
    if called then
      return cached_result
    end
    called = true
    cached_result = fn(unpack(arg))
    return cached_result
  end
end

local NIL = '$$_NIL_$$'
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

local function system(cmd)
  local output = vim.fn.system(cmd)
  if vim.v.shell_error ~= 0 then
    return error(output)
  end
  return vim.trim(output)
end

local function is_system_success(cmd)
  vim.fn.system(cmd)
  return vim.v.shell_error == 0
end

local is_hg_repo = memoize_once(function()
  return is_system_success({ 'hg', 'root' })
end)

local function git_get_repo_root()
  return system({ 'git', 'rev-parse', '--show-toplevel' })
end

local function hg_get_repo_root()
  return system({ 'hg', 'root' })
end

local get_repo_root = memoize_once(function()
  return is_hg_repo() and hg_get_repo_root() or git_get_repo_root()
end)

local function get_project_id()
  local project = vim.split(system({ 'arc', 'get-config', 'project_id' }), ':')
  return vim.trim(project[2])
end

local function git_get_commit_hash_from_diff_id(diff_id)
  return system({ 'git', 'log', '-1', '--format=%H', '--grep', diff_id })
end

local function git_get_branch_name_from_commit_hash(commit_hash)
  return vim.split(
    system({ 'git', 'name-rev', '--name-only', commit_hash })
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
  system({ 'git', 'checkout', branch_name })
end

local function hg_checkout_diff(diff_id)
  system({ 'hg', 'checkout', diff_id })
end

local function checkout_diff(diff_id)
  if is_hg_repo() then
    return hg_checkout_diff(diff_id)
  else
    return git_checkout_diff(diff_id)
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
  -- Same as:
  -- jf list --status NEEDS_REVIEW ACCEPTED CHANGES_PLANNED NEEDS_REVISION | tail -n +2
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

local function diff_file_picker(opts)
  pickers.new(opts, {
    prompt_title = "Changed files on [" .. opts.diff.id .. "] " .. opts.diff.title,
    finder = get_diff_files_finder(opts),
    sorter = conf.generic_sorter(opts),
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
        print(vim.inspect(selection))
        diff_file_picker(selection)
      end)
      return true
    end,
  }):find()
end

return {
  diff_picker = diff_picker
}
