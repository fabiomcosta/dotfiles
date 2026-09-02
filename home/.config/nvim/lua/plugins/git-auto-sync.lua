--- git-auto-sync: auto commit/push changes in git dirs and pull on
--- startup — all asynchronously.
---
--- The plugin itself is generic: paths come *only* from setup() options.
--- Here we feed it the workspaces configured for obsidian.nvim — reading
--- them from the user config (`Obsidian._user_opts.workspaces`, or the
--- lazy.nvim spec before obsidian loads), not from inside the plugin.
--- Note we deliberately avoid `Obsidian.workspaces`, which contains
--- obsidian's synthetic ".obsidian.wiki" workspace (its docs dir inside
--- the lazy clone) alongside the user-defined ones.
---
--- Options (all optional):
---   workspaces      = { '~/Notes/personal', '~/Notes/work', ... }  -- static paths
---   get_workspaces  = fun() -> {...}  -- re-read dynamically on each poll
---   interval        = 60,             -- seconds between background polls
---   debounce        = 5,              -- seconds to coalesce file events
---   pull_on_start   = true,           -- `git pull` when nvim starts
---   pull_mode       = 'ff-only',      -- 'ff-only' | 'rebase' | 'merge'
---   auto_commit     = true,           -- commit changes automatically
---   auto_push       = true,           -- push after commit / when ahead
---   watch_fs        = true,           -- live fs events (FSEvents/inotify)
---   exclude         = { '.obsidian/workspace.json' }, -- git pathspec excludes
---   notify          = true,           -- vim.notify warnings on failures
---   statusline      = {               -- lualine status (state changes refresh it)
---     enabled = true,
---     icons   = { synced = '✓', unsynced = '✗' },
---   },
---   lualine_a = { 'branch', "require('git-auto-sync').status()" }
local function obsidian_workspace_specs()
  -- 1) If obsidian.nvim is already set up, use its RAW user config
  --    (exactly what was passed to setup(), functions untouched).
  --
  --    Important: `Obsidian.workspaces` is NOT used here — obsidian
  --    appends its own synthetic ".obsidian.wiki" workspace (its docs
  --    dir, inside the lazy.nvim clone of obsidian.nvim — a git repo we
  --    must not commit/push into). `Obsidian._user_opts` is the only
  --    source that contains exactly the workspaces the user defined.
  local obsidian = rawget(_G, 'Obsidian')
  if obsidian and type(obsidian._user_opts) == 'table' then
    local workspaces = obsidian._user_opts.workspaces
    if type(workspaces) == 'table' and #workspaces > 0 then
      return vim.deepcopy(workspaces)
    end
  end

  -- 2) Otherwise read the raw `opts.workspaces` from the lazy.nvim spec
  --    for obsidian.nvim (available even before obsidian is lazy-loaded).
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

return {
  {
    name = 'git-auto-sync',
    dir = vim.fs.joinpath(vim.fn.stdpath('config'), 'lua', 'git-auto-sync'),
    lazy = false,
    priority = 600,
    config = function()
      require('git-auto-sync').setup({
        workspaces = obsidian_workspace_specs(),
        -- Re-evaluated on every poll so directories that only appear
        -- later (e.g. after obsidian.nvim lazy-loads) get synced too.
        get_workspaces = obsidian_workspace_specs,
        -- interval = 60,
        -- pull_mode = 'ff-only',
        -- exclude = {},
      })
    end,
  },
}