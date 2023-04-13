-- @lint-ignore-every LUA_LUAJIT
local has_telescope, _ = pcall(require, 'telescope')

if not has_telescope then
  error('This plugins requires nvim-telescope/telescope.nvim')
end

local pickers = require('telescope.pickers')
local async_job_finder = require('telescope.finders.async_job_finder')
local distant = require('distant')
local utils = require('telescope._extensions.utils')

-- TODO this is an option or path of a distant-project plugin setup
local distant_project = {
  config = {
    cwd = '/home/fabs/www',
  },
}

local function myles(opts)
  local local_cwd = opts.cwd and vim.fn.expand(opts.cwd) or vim.loop.cwd()
  opts.cwd = local_cwd
  opts.max_results = opts.max_results or vim.o.lines or 100

  local remote_cwd = distant_project.config.cwd

  -- myles requires an hg repo to work
  if utils.has_hg_root(remote_cwd) == nil then
    vim.notify('No hg root found for: ' .. remote_cwd, vim.log.levels.ERROR)
    return nil
  end

  if not opts.entry_maker then
    opts.entry_maker = function(value)
      local filename = remote_cwd .. '/' .. value
      return {
        value = value,
        display = value,
        ordinal = value,
        filename = filename,
        path = 'distant://' .. filename,
      }
    end
  end

  local finder_opts = vim.tbl_extend('force', {
    command_generator = function(prompt)
      if not prompt or prompt == '' then
        return nil
      end
      local cmd = {
        'myles',
        '--list',
        '--limit',
        opts.max_results,
        '--client',
        'nvim',
        prompt,
      }
      return distant.wrap({ cmd = cmd, cwd = remote_cwd })
    end,
  }, opts)

  pickers
    .new(opts, {
      prompt_title = 'Find files using Myles',
      finder = async_job_finder(finder_opts),
      previewer = utils.distant_buffer_previewer(opts),
    })
    :find()
end

return require('telescope').register_extension({
  exports = {
    distant_myles = myles,
  },
})
