--- :checkhealth support for git-auto-sync.
local M = {}

M.check = function()
  vim.health.start('git-auto-sync')

  if vim.fn.executable('git') ~= 1 then
    vim.health.error('`git` binary not found in PATH — nothing will be synced.')
    return
  end
  vim.health.ok('git binary found')

  local plugin = require('git-auto-sync')
  local workspaces = plugin.resolve_workspaces()

  if #workspaces == 0 then
    vim.health.warn(
      'No workspaces configured.\n'
        .. '  * Pass `workspaces` (or `get_workspaces`) to require("git-auto-sync").setup().\n'
        .. '  * This config wires the obsidian.nvim workspaces in plugins/git-auto-sync.lua.'
    )
    return
  end

  vim.health.info(('configured workspace(s): %d'):format(#workspaces))
  for _, ws in ipairs(workspaces) do
    local name = ws.name or vim.fn.fnamemodify(ws.path, ':t')
    local is_repo = vim.fn.system({ 'git', '-C', ws.path, 'rev-parse', '--is-inside-work-tree' })
    if vim.v.shell_error == 0 and vim.trim(is_repo) == 'true' then
      vim.health.ok(('%s (%s) — git repo, will auto-sync'):format(name, ws.path))
    else
      vim.health.warn(('%s (%s) — not a git repository, skipped'):format(name, ws.path))
    end
  end
end

return M