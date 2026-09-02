--- git-auto-sync — automatic git sync for a list of directories.
---
--- A generic, config-driven plugin: you hand it the directory paths you
--- want to keep in sync (workspaces, vaults, dotfiles, ...) and it commits
--- and pushes every change, and pulls from the remote on startup — all
--- asynchronously, so the UI is never blocked.
---
--- Workspace paths are provided exclusively through `setup()` — the
--- plugin knows nothing about obsidian.nvim or any other source.
--- (This config wires it up with the obsidian.nvim workspaces in
--- `plugins/git-auto-sync.lua`.)
---
--- Behavior
---   * On startup (and when a workspace is first discovered), for every
---     configured directory that is a git repo:
---       1. commit any local changes,
---       2. `git pull` from the remote (default `--ff-only`),
---       3. push if local is ahead of the remote.
---   * Afterwards, local file changes (added, removed, modified) are
---     detected through filesystem events (FSEvents/inotify) and a gentle
---     background poll, then committed and pushed automatically.
---
--- All git work runs through `vim.system`; file watching through
--- `vim.uv.fs_event`; warnings through `vim.notify`. Nothing here ever
--- blocks the editor, and successful commits/pushes are silent — sync
--- state is surfaced through `require('git-auto-sync').status()` for
--- lualine instead (✓ in sync, ✗ when there is anything to push).
---
--- Quick reference
---   * `require('git-auto-sync').status()` — lualine icon for the current buffer
---   * `:GitAutoSync sync`    — commit + pull + push all repos right now
---   * `:GitAutoSync status`  — one-line summary per workspace
---   * `:GitAutoSync check`   — re-verify repos, (re)discover workspaces
---   * `:GitAutoSync enable` / `:GitAutoSync disable` — pause/resume
---   * `:checkhealth git-auto-sync`
---
---@module git-auto-sync

local sync = require('git-auto-sync.sync')

local M = {}

---@class git-auto-sync.Config
---@field workspaces (string|{path:string,name?:string}|fun():string|{path:string,name?:string})[] Directories to sync. Paths may be strings (with `~`), tables with `path`/`name`, or functions returning either.
---@field get_workspaces fun():(string|table)[]|? Called on startup and on every poll to discover new directories. Returned entries are merged with `workspaces` (deduped by absolute path).
---@field interval integer Seconds between background polls (default 60).
---@field debounce integer Seconds to coalesce rapid file events (default 5).
---@field pull_on_start boolean Pull from the remote on startup (default true).
---@field pull_mode 'ff-only'|'rebase'|'merge' How to pull (default 'ff-only').
---@field auto_commit boolean Auto-commit dirty trees (default true).
---@field auto_push boolean Auto-push after commit / when ahead (default true).
---@field watch_fs boolean Watch workspaces with fs events (default true).
---@field exclude string[] Git pathspec excludes, e.g. {'.obsidian/workspace.json'} (default {}).
---@field notify boolean Emit vim.notify warnings on failures (default true).
---@field log_level integer Default vim.log.levels level (default INFO).
---@field commit_subject fun(st: table, files: string[]):string|? Override commit subject.
---@field statusline { enabled?: boolean, icons?: { synced?: string, unsynced?: string } } Lualine status: `require('git-auto-sync').status()` returns the icon for the current buffer (markdown files inside a workspace only); state changes trigger an automatic statusline refresh (default enabled, icons '✓' / '✗').
local DEFAULT_CONFIG = {
  workspaces = {},
  get_workspaces = nil,
  interval = 60,
  debounce = 5,
  pull_on_start = true,
  pull_mode = 'ff-only',
  auto_commit = true,
  auto_push = true,
  watch_fs = true,
  exclude = {},
  notify = true,
  log_level = vim.log.levels.INFO,
  commit_subject = nil,
  statusline = {
    enabled = true,
    icons = { synced = '✓', unsynced = '✗' },
  },
}

M.config = {}

-- path (absolute, normalized) -> state
local states = {}
-- path -> uv fs_event handle (kept referenced so it is not GC'd)
local watchers = {}
-- timer handle
local poll_timer
-- autocmd group + loaded guard
local augroup
local loaded = false

local uv = vim.uv or vim.loop

-- discover_missing is part of a cycle with the poll loop
-- (poll -> verify -> fs watch -> debounced poll) and is referenced before
-- its definition, so the name is declared here and later *assigned* —
-- a re-`local` declaration would shadow this upvalue and leave the early
-- references pointing at nil.
local discover_missing

-- ---------------------------------------------------------------------------
-- Small helpers
-- ---------------------------------------------------------------------------

local now_ms = function()
  return uv.now()
end

local trim = function(s)
  return (s:gsub('^%s+', ''):gsub('%s+$', ''))
end

local short_err = function(s)
  return trim(s):sub(1, 400)
end

local display_name = function(st)
  if st.name and st.name ~= '' then
    return tostring(st.name)
  end
  return vim.fn.fnamemodify(st.path, ':t') or st.path
end

local notify = function(msg, level)
  vim.notify('[git-auto-sync] ' .. msg, level or M.config.log_level, { title = 'git-auto-sync' })
end

---Notify only once per workspace per key (until the key is reset on success).
local warn_once = function(st, key, msg)
  if st.warned[key] then
    return
  end
  st.warned[key] = true
  notify(msg, vim.log.levels.WARN)
end

---Trigger a lualine refresh (if lualine is loaded) and redraw the
---statusline, so the sync icon updates asynchronously without waiting for
---a window/buffer event.
local refresh_statusline = function()
  if not M.config.statusline.enabled then
    return
  end
  vim.schedule(function()
    pcall(function()
      require('lualine').refresh()
    end)
    vim.cmd.redrawstatus()
  end)
end

---Track a workspace's sync state and refresh the statusline on change.
---`true` = clean tree and nothing to push; `false` = uncommitted changes
---and/or unpushed commits — both show as the "not in sync" icon.
---@param st table
---@param synced boolean
local set_synced = function(st, synced)
  if st.synced == synced then
    return
  end
  st.synced = synced
  refresh_statusline()
end

-- ---------------------------------------------------------------------------
-- Workspace configuration -> paths
-- ---------------------------------------------------------------------------

---Evaluate a workspace entry down to a raw path string.
---@param entry any
---@return string|nil
local eval_entry = function(entry)
  -- Iterative unwrap (a function may return a path or another function).
  -- Note: this loop avoids a self-recursive call, which would be
  -- out-of-scope inside a `local x = function() ...` initializer.
  while true do
    if type(entry) == 'function' then
      local ok, res = pcall(entry)
      if not ok then
        return nil
      end
      entry = res
    elseif type(entry) == 'string' then
      return entry
    elseif type(entry) == 'table' then
      entry = entry.path
    else
      return nil
    end
  end
end

---Normalize a raw path: expand `~`/env vars, normalize `..`, follow
---symlinks when the directory exists.
---@param raw string
---@return string|nil
local normalize_path = function(raw)
  local expanded = vim.fn.expand(raw)
  if expanded == '' then
    expanded = raw
  end
  local normalized = vim.fs.normalize(expanded)
  local real = uv.fs_realpath(normalized)
  if real then
    return real
  end
  return normalized
end

---Collect and dedupe configured workspaces (static `workspaces` +
---dynamic `get_workspaces` results).
---@return { path: string, name: string|? }[]
local collect_workspaces = function()
  local seen = {}
  local out = {}

  local add = function(entry)
    local raw = eval_entry(entry)
    if not raw then
      return
    end
    local normalized = normalize_path(raw)
    if not normalized or seen[normalized] then
      return
    end
    seen[normalized] = true
    local name = type(entry) == 'table' and entry.name or nil
    table.insert(out, { path = normalized, name = name })
  end

  for _, entry in ipairs(M.config.workspaces or {}) do
    add(entry)
  end
  if M.config.get_workspaces then
    local ok, res = pcall(M.config.get_workspaces)
    if ok and type(res) == 'table' then
      for _, entry in ipairs(res) do
        add(entry)
      end
    end
  end

  return out
end

-- ---------------------------------------------------------------------------
-- Async git sequences
-- ---------------------------------------------------------------------------

---Run a sequence of async steps in order. Each step is
---`function(next) ... end`; a step aborts the chain by calling `next(false)`.
local chain = function(steps, done)
  local i = 1
  local function run()
    if i > #steps then
      if done then
        done()
      end
      return
    end
    local step = steps[i]
    i = i + 1
    step(run)
  end
  run()
end

---Parse `--porcelain -z` output into a list of relative file paths.
---Only affects the commit message; `git add -A` is always correct.
---@param porcelain string
---@return string[]
local parse_porcelain = function(porcelain)
  if porcelain == '' then
    return {}
  end
  local files = {}
  -- `--porcelain -z` separates records with NUL. vim.split with
  -- {plain=true} does no pattern matching, so NUL bytes are fine.
  for _, chunk in ipairs(vim.split(porcelain, '\0', { plain = true })) do
    -- chunk format: "XY <path>" (unmerged: "XY  <path>"); renames/copies
    -- emit a second bare record which we skip.
    if #chunk >= 4 then
      local rel = chunk:sub(4)
      if rel ~= '' then
        files[#files + 1] = rel
      end
    end
  end
  return files
end

local default_subject = function(st, files)
  local n = #files
  return ('chore(sync): auto-sync %s — %d change%s'):format(
    display_name(st),
    n,
    n == 1 and '' or 's'
  )
end

local default_body = function(st, files)
  local lines = {
    ('Auto-sync by git-auto-sync at %s'):format(os.date('%Y-%m-%d %H:%M:%S')),
    '',
  }
  for i = 1, math.min(#files, 12) do
    lines[#lines + 1] = ('- %s'):format(files[i])
  end
  if #files > 12 then
    lines[#lines + 1] = ('- ... and %d more'):format(#files - 12)
  end
  return table.concat(lines, '\n')
end

local build_messages = function(st, files)
  local subject = M.config.commit_subject
    and M.config.commit_subject(st, files)
    or default_subject(st, files)
  return subject, default_body(st, files)
end

---Commit a dirty tree and push it (busy-guarded).
---Re-read the ground truth (status + ahead parity) after a sync
---operation and update `st.synced` accordingly.
---@param st table
---@param done fun()|?
local finalize_sync = function(st, done)
  sync.status(st, function(_, porcelain)
    local p = porcelain
    sync.upstream_ahead(st, function(ahead, _)
      st.last_porcelain = p
      st.last_ahead = ahead
      set_synced(st, p == '' and ahead == 0)
      if done then
        done()
      end
    end)
  end)
end

---Commit a dirty tree and push it (busy-guarded; callers must check
---`st.busy` before calling). No success notifications are emitted —
---state is surfaced through `M.status()` for lualine instead.
---@param st table
---@param porcelain string
---@param done fun()|?
local commit_and_push = function(st, porcelain, done)
  if st.busy then
    if done then
      done()
    end
    return
  end
  st.busy = true
  st.busy_since = now_ms()
  st.just_pushed = false
  set_synced(st, false)

  local files = parse_porcelain(porcelain)
  local subject, body = build_messages(st, files)

  sync.commit(st, subject, body, function(code, err)
    if code ~= 0 then
      warn_once(st, 'commit', ('commit failed in %s: %s'):format(display_name(st), short_err(err)))
      st.busy = false
      finalize_sync(st, done)
      return
    end
    st.warned.commit = nil
    st.last_porcelain = ''

    if not M.config.auto_push then
      st.busy = false
      finalize_sync(st, done)
      return
    end

    sync.push(st, function(pcode, _, perr)
      if pcode ~= 0 then
        warn_once(st, 'push', ('push failed in %s: %s'):format(display_name(st), short_err(perr)))
      else
        st.warned.push = nil
        st.warned.upstream = nil
        st.just_pushed = true
      end
      st.busy = false
      finalize_sync(st, done)
    end)
  end)
end

---Pull from the remote. Warnings are rate-limited; a successful pull resets
---the rate limit so the next failure is reported again.
---@param st table
---@param done fun()|?
local do_pull = function(st, done)
  sync.pull(st, M.config.pull_mode, function(code, _, err)
    if code == 0 then
      st.warned.pull = nil
      st.warned.upstream = nil
      finalize_sync(st, done)
    else
      warn_once(st, 'pull', ('pull failed in %s: %s'):format(display_name(st), short_err(err)))
      set_synced(st, false)
      if done then
        done()
      end
    end
  end)
end

---Push commits that are ahead of the upstream, if any (busy-guarded).
---Also updates the sync state from the given `porcelain` (defaults to the
---last known status) and the upstream parity.
---@param st table
---@param porcelain string|nil
---@param done fun()|?
local push_if_ahead = function(st, porcelain, done)
  porcelain = porcelain or (st.last_porcelain or '')
  if st.busy then
    if done then
      done()
    end
    return
  end
  sync.upstream_ahead(st, function(ahead, has_upstream)
    st.last_ahead = ahead
    st.last_porcelain = porcelain
    if not has_upstream then
      set_synced(st, porcelain == '')
      warn_once(st, 'upstream', ('%s: no upstream branch — pull/push disabled (%s)'):format(display_name(st), st.path))
      if done then
        done()
      end
      return
    end
    if ahead <= 0 then
      set_synced(st, porcelain == '')
      if done then
        done()
      end
      return
    end
    set_synced(st, false)
    if not M.config.auto_push then
      if done then
        done()
      end
      return
    end
    st.busy = true
    st.busy_since = now_ms()
    sync.push(st, function(code, _, err)
      if code ~= 0 then
        warn_once(st, 'push', ('push failed in %s: %s'):format(display_name(st), short_err(err)))
      else
        st.warned.push = nil
        st.warned.upstream = nil
        st.just_pushed = true
      end
      st.busy = false
      finalize_sync(st, done)
    end)
  end)
end

---Startup / manual sync sequence for a workspace:
---commit local changes -> pull -> push (if still ahead).
---@param st table
---@param opts { pull?: boolean }
local startup_sync = function(st, opts)
  if st.busy then
    return
  end

  local steps = {}

  if M.config.auto_commit then
    steps[#steps + 1] = function(next)
      sync.status(st, function(code, porcelain)
        if code ~= 0 then
          next(false)
          return
        end
        st.last_porcelain = porcelain
        if porcelain == '' then
          next()
          return
        end
        commit_and_push(st, porcelain, function()
          next()
        end)
      end)
    end
  end

  if opts.pull then
    -- Guard the pull step specifically: it must not race with the poll
    -- loop (git operations on the same repo must be serialized).
    steps[#steps + 1] = function(next)
      st.busy = true
      do_pull(st, function()
        st.busy = false
        next()
      end)
    end
  end

  if M.config.auto_push then
    steps[#steps + 1] = function(next)
      push_if_ahead(st, nil, next)
    end
  end

  chain(steps)
end

-- ---------------------------------------------------------------------------
-- Background polling (defined before the fs watcher, which feeds into it)
-- ---------------------------------------------------------------------------

local event_pending = false

---Periodic poll: re-discover workspaces (honors `get_workspaces`), commit
---+ push anything dirty, push commits ahead of the remote.
local periodic_check = function()
  if not M.config.enabled then
    return
  end
  discover_missing()
  -- Snapshot so callbacks scheduling more work can't mutate the loop.
  local snapshot = vim.tbl_values(states)
  for _, st in ipairs(snapshot) do
    if st.is_repo and not st.busy then
      sync.status(st, function(code, porcelain)
        if code ~= 0 then
          return
        end
        st.last_porcelain = porcelain
        if st.busy then
          return
        end
        if porcelain ~= '' then
          set_synced(st, false)
          commit_and_push(st, porcelain)
        else
          push_if_ahead(st, porcelain)
        end
      end)
    end
  end
end

---Coalesce bursty file events into a single check (defined after
---`periodic_check`, which its deferred callback references).
local debounced_check = function()
  if event_pending then
    return
  end
  event_pending = true
  vim.defer_fn(function()
    event_pending = false
    periodic_check()
  end, M.config.debounce * 1000)
end

-- ---------------------------------------------------------------------------
-- Buffer events (edits made inside nvim)
-- ---------------------------------------------------------------------------

local on_buffer_event = function()
  local file = vim.fn.fnamemodify(vim.fn.expand('<afile>'), ':p')
  if file == '' then
    return
  end
  for path, st in pairs(states) do
    if st.is_repo and (file == path or vim.startswith(file, path .. '/')) then
      debounced_check()
      return
    end
  end
end

-- ---------------------------------------------------------------------------
-- Filesystem watching (external changes)
-- ---------------------------------------------------------------------------

local is_git_internal = function(filename)
  local f = tostring(filename):gsub('^%./', '')
  if f == '.git' then
    return true
  end
  for seg in vim.gsplit(f, '/', { plain = true }) do
    if seg == '.git' then
      return true
    end
  end
  return false
end

local start_watcher = function(st)
  if not M.config.watch_fs then
    return
  end
  local ok, ev = pcall(uv.new_fs_event)
  if not ok or not ev then
    return
  end
  local started = ev:start(st.path, { recursive = true }, function(err, filename)
    if err or not M.config.enabled then
      return
    end
    if filename and is_git_internal(filename) then
      return -- our own git bookkeeping, ignore
    end
    debounced_check()
  end)
  if started then
    watchers[st.path] = ev
  end
end

local stop_watchers = function()
  for _, ev in pairs(watchers) do
    pcall(function()
      ev:stop()
    end)
  end
  watchers = {}
end

-- ---------------------------------------------------------------------------
-- Workspace discovery / verification
-- ---------------------------------------------------------------------------

---Verify whether a workspace is a git repo. On first verification of a repo,
---attach a filesystem watcher and run the startup sync sequence.
---@param st table
---@param is_new boolean
local verify = function(st, is_new)
  sync.is_git_repo(st, function(is_repo)
    st.is_repo = is_repo
    if not is_repo then
      if is_new then
        notify(
          ('%s: not a git repository — will not sync (%s)'):format(display_name(st), st.path),
          vim.log.levels.INFO
        )
      end
      return
    end
    if is_new then
      start_watcher(st)
      startup_sync(st, { pull = M.config.pull_on_start })
    end
  end)
end

---Add newly-configured workspaces and run the startup sequence
---(verify repo -> pull -> push) for them. Assignment completes the
---poll/watch/discovery cycle; see the declaration at the top.
discover_missing = function()
  for _, ws in ipairs(collect_workspaces()) do
    if not states[ws.path] then
      local st = {
        path = ws.path,
        name = ws.name,
        exclude = M.config.exclude,
        busy = false,
        busy_since = nil,
        is_repo = nil, -- nil = unknown, boolean once verified
        synced = nil, -- nil = unknown, boolean once verified (true = clean + nothing to push)
        warned = {},
        just_pushed = false,
        last_porcelain = '',
        last_ahead = 0,
      }
      states[ws.path] = st
      verify(st, true)
    end
  end
end

-- ---------------------------------------------------------------------------
-- Commands
-- ---------------------------------------------------------------------------

local command_status = function()
  local paths = vim.tbl_keys(states)
  table.sort(paths)
  if #paths == 0 then
    notify(
      'no workspaces configured. Pass `workspaces` to require("git-auto-sync").setup()',
      vim.log.levels.INFO
    )
    return
  end

  local lines = {}
  local remaining = #paths
  local done_line = function()
    remaining = remaining - 1
    if remaining == 0 then
      notify(table.concat(lines, '\n'), vim.log.levels.INFO)
    end
  end

  for _, p in ipairs(paths) do
    local st = states[p]
    local name = display_name(st)
    if st.is_repo ~= true then
      lines[#lines + 1] = ('- %s [%s] %s'):format(
        name,
        st.is_repo == nil and 'checking…' or 'not a git repo',
        p
      )
      done_line()
    else
      sync.status(st, function(code, porcelain)
        st.last_porcelain = porcelain
        sync.upstream_ahead(st, function(ahead, _)
          st.last_ahead = ahead
          lines[#lines + 1] = ('- %s [git repo] %s | dirty=%s | ahead=%d%s'):format(
            name,
            p,
            tostring(code == 0 and porcelain ~= ''),
            ahead,
            st.busy and ' | busy' or ''
          )
          done_line()
        end)
      end)
    end
  end
end

local command_handler = function(args)
  local what = (args.args ~= '' and args.args) or 'status'
  if what == 'sync' then
    local n = 0
    for _, st in pairs(states) do
      if st.is_repo then
        n = n + 1
        startup_sync(st, { pull = true })
      end
    end
    notify(('forced sync for %d repo(s)'):format(n), vim.log.levels.INFO)
  elseif what == 'status' then
    command_status()
  elseif what == 'check' then
    discover_missing()
    for _, st in pairs(states) do
      verify(st, false)
    end
    notify('re-checked workspaces', vim.log.levels.INFO)
  elseif what == 'enable' then
    M.config.enabled = true
    notify('enabled — resume polling and file watching', vim.log.levels.INFO)
    periodic_check()
  elseif what == 'disable' then
    M.config.enabled = false
    notify('disabled — polling and file watching paused', vim.log.levels.INFO)
  else
    notify('usage: GitAutoSync [sync|status|check|enable|disable]', vim.log.levels.ERROR)
  end
end

-- ---------------------------------------------------------------------------
-- Setup / teardown
-- ---------------------------------------------------------------------------

local cleanup = function()
  if poll_timer then
    vim.fn.timer_stop(poll_timer)
    poll_timer = nil
  end
  stop_watchers()
end

---Setup git-auto-sync.
---@param user_opts? git-auto-sync.Config
M.setup = function(user_opts)
  M.config = vim.tbl_deep_extend('force', vim.deepcopy(DEFAULT_CONFIG), user_opts or {})
  M.config.interval = math.max(1, M.config.interval)
  M.config.debounce = math.max(1, M.config.debounce)
  M.config.enabled = true

  if loaded then
    return
  end
  loaded = true

  augroup = vim.api.nvim_create_augroup('git_auto_sync', { clear = true })

  -- Detect edits made inside nvim (add/remove/change).
  for _, event in ipairs({ 'BufWritePost', 'BufAdd', 'BufDelete', 'BufCreate' }) do
    vim.api.nvim_create_autocmd(event, {
      group = augroup,
      pattern = '*',
      callback = on_buffer_event,
    })
  end

  vim.api.nvim_create_autocmd('VimLeavePre', {
    group = augroup,
    callback = cleanup,
  })

  vim.api.nvim_create_user_command(
    'GitAutoSync',
    command_handler,
    {
      nargs = '?',
      desc = 'git-auto-sync: commit/push changes, pull on startup',
      complete = function()
        return { 'sync', 'status', 'check', 'enable', 'disable' }
      end,
    }
  )

  -- Start after config finishes; everything downstream is async.
  vim.schedule(function()
    discover_missing()
    if next(states) == nil then
      notify('no workspaces configured — pass `workspaces` to setup()', vim.log.levels.INFO)
    end
    poll_timer = vim.fn.timer_start(M.config.interval * 1000, function()
      periodic_check()
    end, { ['repeat'] = -1 })
  end)
end

---Resolve the configured workspace list (used by checkhealth / integrations).
---@return { path: string, name: string|? }[]
M.resolve_workspaces = function()
  if not loaded then
    return {}
  end
  return collect_workspaces()
end

---Status icon for lualine.
---
---Returns the sync icon only when all of these hold:
---  * the buffer is a markdown file,
---  * it lives inside one of the configured workspaces (which is a git repo),
---  * the workspace sync state is known.
---Returns `''` otherwise (so the component renders nothing).
---
---Both "uncommitted changes" and "unpushed commits" map to the same
---'unsynced' icon; only a clean tree *and* nothing ahead shows 'synced'.
---
---```lua
----- lualine
---{
---  sections = {
---    lualine_a = { 'branch', "require('git-auto-sync').status()" },
---  },
---}
---```
---
---@param opts? { buf?: integer } Defaults to the current buffer.
---@return string
M.status = function(opts)
  opts = opts or {}
  local buf = opts.buf or 0

  local ok_ft, ft = pcall(function()
    return vim.bo[buf].ft
  end)
  if not ok_ft or ft ~= 'markdown' then
    return ''
  end

  local name = vim.fs.normalize(vim.api.nvim_buf_get_name(buf))
  if name == '' then
    return ''
  end

  for path, st in pairs(states) do
    if st.is_repo and (name == path or vim.startswith(name, path .. '/')) then
      if st.synced == nil then
        return ''
      end
      return st.synced and M.config.statusline.icons.synced or M.config.statusline.icons.unsynced
    end
  end
  return ''
end

-- Exposed for tests/integration.
M._states = states
M._periodic_check = periodic_check
M._startup_sync = startup_sync

return M