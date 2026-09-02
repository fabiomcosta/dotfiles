--- Async git primitives for git-auto-sync.
---
--- Every operation runs through `vim.system` (libuv child process), so
--- nothing here ever blocks the editor loop. Callbacks run on the main
--- loop (after `vim.schedule`) and receive `(code, stdout, stderr)`.
---
---@module git-auto-sync.sync

local M = {}

local unpack_ = table.unpack or unpack

---Run a git command inside a workspace, asynchronously.
---@param ws table # workspace with a `path` field
---@param args string[]
---@param on_done fun(code: integer, stdout: string, stderr: string)
M.git = function(ws, args, on_done)
  vim.system({ 'git', '-C', ws.path, unpack_(args) }, { text = true }, function(out)
    vim.schedule(function()
      on_done(out.code, out.stdout or '', out.stderr or '')
    end)
  end)
end

---Check whether the workspace is a git repository.
---@param ws table
---@param on_done fun(is_repo: boolean)
M.is_git_repo = function(ws, on_done)
  M.git(ws, { 'rev-parse', '--is-inside-work-tree' }, function(code, stdout, _)
    on_done(code == 0 and vim.trim(stdout) == 'true')
  end)
end

---Read `git status --porcelain -z`.
---
---`exclude` is a list of git pathspec exclude patterns (relative to the
---workspace root), e.g. `{ '.obsidian/workspace.json' }`.
---@param ws table
---@param on_done fun(code: integer, porcelain: string, stderr: string)
M.status = function(ws, on_done)
  local args = { 'status', '--porcelain', '-z' }
  local exclude = ws.exclude or {}
  if #exclude > 0 then
    args[#args + 1] = '--'
    args[#args + 1] = '.'
    for _, pat in ipairs(exclude) do
      args[#args + 1] = ':(exclude)' .. pat
    end
  end
  M.git(ws, args, on_done)
end

---Stage everything (`git add -A`, honors `ws.exclude`) and commit.
---@param ws table
---@param subject string
---@param body string
---@param on_done fun(code: integer, stderr: string) # code == 0 on success
M.commit = function(ws, subject, body, on_done)
  local add_args = { 'add', '-A' }
  local exclude = ws.exclude or {}
  if #exclude > 0 then
    add_args[#add_args + 1] = '--'
    add_args[#add_args + 1] = '.'
    for _, pat in ipairs(exclude) do
      add_args[#add_args + 1] = ':(exclude)' .. pat
    end
  end
  M.git(ws, add_args, function(code, _, err)
    if code ~= 0 then
      on_done(code, err)
      return
    end
    M.git(ws, { 'commit', '-m', subject, '-m', body }, function(c, _, serr)
      on_done(c, serr)
    end)
  end)
end

---Push to the current branch's upstream (`git push`).
---@param ws table
---@param on_done fun(code: integer, stdout: string, stderr: string)
M.push = function(ws, on_done)
  M.git(ws, { 'push' }, on_done)
end

---Pull from the upstream. `mode` is one of `'ff-only' | 'rebase' | 'merge'`.
---@param ws table
---@param mode string
---@param on_done fun(code: integer, stdout: string, stderr: string)
M.pull = function(ws, mode, on_done)
  local args = { 'pull' }
  if mode == 'rebase' then
    args[#args + 1] = '--rebase'
  elseif mode == 'merge' then
    args[#args + 1] = '--no-rebase'
  else
    args[#args + 1] = '--ff-only'
  end
  M.git(ws, args, on_done)
end

---How many commits the local branch is ahead of its upstream, and whether
---an upstream branch exists at all.
---@param ws table
---@param on_done fun(ahead: integer, has_upstream: boolean)
M.upstream_ahead = function(ws, on_done)
  M.git(ws, { 'rev-parse', '--abbrev-ref', '@{upstream}' }, function(code, _, _)
    if code ~= 0 then
      on_done(0, false)
      return
    end
    M.git(ws, { 'rev-list', '--count', '@{upstream}..HEAD' }, function(c2, count, _)
      on_done(tonumber(vim.trim(count)) or 0, true)
    end)
  end)
end

return M