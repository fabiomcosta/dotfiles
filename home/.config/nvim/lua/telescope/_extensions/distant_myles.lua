-- @lint-ignore-every LUA_LUAJIT
local has_telescope, _ = pcall(require, 'telescope')

if not has_telescope then
  error('This plugins requires nvim-telescope/telescope.nvim')
end

local previewers = require('telescope.previewers')
local pickers = require('telescope.pickers')
local async_job_finder = require('telescope.finders.async_job_finder')
local distant = require('distant')

-- TODO this is an option or path of a distant-project plugin setup
local distant_project = {
  config = {
    cwd = '/home/fabs/www',
  },
}

-- TODO make this async
local function system(opts)
  local output = vim.fn.system(distant.wrap(opts))
  if vim.v.shell_error ~= 0 then
    return nil
  end
  return vim.trim(output)
end

local function myles(opts)
  local local_cwd = opts.cwd and vim.fn.expand(opts.cwd) or vim.loop.cwd()
  opts.cwd = local_cwd
  opts.max_results = opts.max_results or vim.o.lines or 100

  local remote_cwd = distant_project.config.cwd

  -- myles requires an hg repo to work
  local project_root = system({ cmd = { 'hg', 'root' }, cwd = remote_cwd })
  if project_root == nil then
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

  -- TODO do we need this?
  if opts.path_display == nil then
    opts.path_display = function(_, path)
      return path
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

  local previewer_opts = vim.tbl_extend('force', {
    get_command = function(entry)
      return distant.wrap({ cmd = { 'cat', entry.filename } })
    end,
  }, opts)

  pickers
    .new(opts, {
      prompt_title = 'Find files using Myles',
      finder = async_job_finder(finder_opts),
      previewer = previewers.new_termopen_previewer(previewer_opts),
    })
    :find()
end

return require('telescope').register_extension({
  exports = {
    distant_myles = myles,
  },
})
