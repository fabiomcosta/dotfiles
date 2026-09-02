# git-auto-sync

Generic, fully-asynchronous git sync for a list of directories you give it
in `setup()`. It has no idea what the directories are — this config wires
it up with the obsidian.nvim workspaces (see below).

For every configured directory that is a git repo, `git-auto-sync`:

- **on nvim startup** (and whenever a directory is first discovered):
  1. commits any local changes,
  2. runs `git pull` (default `--ff-only`),
  3. pushes if local is ahead of the remote;
- **while running**, watches the directory for added / removed / modified
  files via filesystem events (FSEvents on macOS, inotify on Linux) plus a
  gentle background poll (default every 60 s), auto-committing and pushing
  the changes.

## How it works

- All git operations run through `vim.system` (libuv child processes);
  file watching through `vim.uv.fs_event`; failures through `vim.notify`.
  Nothing ever runs `vim.fn.system()` on the hot path — the UI never
  blocks.
- Successful commits and pushes are **silent** (no notifications).
  Instead, sync state is exposed through `require('git-auto-sync').status()`
  for lualine, and the statusline refreshes automatically when state
  changes.
- Non-repo directories are detected once and skipped (re-run
  `:GitAutoSync check` after `git init`).
- No force-pushing, ever. Divergences and network errors are reported
  once via `vim.notify` and retried on the next start / `:GitAutoSync sync`.

## Requirements

- Neovim >= 0.10 (`vim.system`, `vim.uv`, `vim.fs`)
- `git` (with a remote + upstream configured for pull/push to work)

## Usage

Paths come only through `setup()` — string paths, `{ path, name }` tables,
functions returning either, or a `get_workspaces` function re-read on each
poll (handy when the source of directories loads lazily):

```lua
require('git-auto-sync').setup({
  -- static paths
  workspaces = {
    '~/Notes/personal',
    { path = '~/Notes/work', name = 'work' },
    function() return vim.fn.stdpath('data') .. '/mysync' end,
  },
  -- dynamic re-discovery (merged with `workspaces`, deduped)
  -- get_workspaces = function() return { ... } end,

  interval      = 60,          -- seconds between background polls
  debounce      = 5,           -- seconds to coalesce file events
  pull_on_start = true,        -- pull from remote on startup
  pull_mode     = 'ff-only',   -- 'ff-only' | 'rebase' | 'merge'
  auto_commit   = true,
  auto_push     = true,
  watch_fs      = true,        -- live fs events (FSEvents/inotify)
  exclude       = {},          -- git pathspec excludes
  notify        = true,
  -- commit_subject = function(st, files) return 'custom subject' end,
})
```

### Wiring it to obsidian.nvim (this config)

The plugin takes plain paths; the obsidian knowledge stays in the user
config. `plugins/git-auto-sync.lua`:

```lua
local function obsidian_workspace_specs()
  -- 1) raw user config once obsidian.nvim has been set up
  --    (Obsidian.workspaces would ALSO return obsidian's synthetic
  --    ".obsidian.wiki" workspace — its docs dir — which we must not touch)
  local obsidian = rawget(_G, 'Obsidian')
  if obsidian and type(obsidian._user_opts) == 'table' then
    local workspaces = obsidian._user_opts.workspaces
    if type(workspaces) == 'table' and #workspaces > 0 then
      return vim.deepcopy(workspaces)
    end
  end
  -- 2) raw opts from the obsidian lazy.nvim spec (pre-load)
  local ok, lazy = pcall(require, 'lazy.core.config')
  if ok and lazy and lazy.plugins and lazy.plugins['obsidian.nvim'] then
    local opts = lazy.plugins['obsidian.nvim'].opts
    if type(opts) == 'function' then
      opts = opts()
    end
    if opts and type(opts.workspaces) == 'table' then
      return vim.deepcopy(opts.workspaces)
    end
  end
  return {}
end

require('git-auto-sync').setup({
  workspaces     = obsidian_workspace_specs(),
  get_workspaces = obsidian_workspace_specs,
})
```

## Statusline (lualine)

Instead of success notifications, the sync state is available as a
function for lualine. The icon only renders for **markdown files inside
one of the configured workspaces**; anywhere else it returns `''`.
Uncommitted changes and unpushed commits both map to the "not in sync"
icon — only a clean tree with nothing ahead shows the "in sync" icon.

```lua
require('lualine').setup({
  sections = {
    lualine_x = { "require('git-auto-sync').status()", 'diagnostics' },
  },
})
```

Icons are configurable (set either to `''` to hide that state):

```lua
require('git-auto-sync').setup({
  statusline = {
    enabled = true,                     -- expose status() + auto-refresh
    icons = { synced = '✓', unsynced = '✗' },
  },
})
```

The statusline is refreshed automatically on every state change
(`require('lualine').refresh()` when lualine is loaded, plus
`redrawstatus`), so the icon updates live after a commit/push cycle
finishes.

## Commands

| Command | Effect |
| --- | --- |
| `:GitAutoSync sync` | commit + pull + push every repo right now |
| `:GitAutoSync status` | one-line summary per directory |
| `:GitAutoSync check` | re-discover / re-verify repositories |
| `:GitAutoSync enable` / `:GitAutoSync disable` | pause / resume |
| `:checkhealth git-auto-sync` | health check |

## Notes / caveats

- Everything in the working tree is committed with `git add -A` — use a
  `.gitignore` (or the `exclude` option) to keep files out of git.
- Changes made *outside* nvim (e.g. in the Obsidian desktop app) are picked
  up by the filesystem watcher and the periodic poll.