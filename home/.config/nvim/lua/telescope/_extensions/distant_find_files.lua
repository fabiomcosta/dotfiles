-- @lint-ignore-every LUA_LUAJIT
local has_telescope, _ = pcall(require, 'telescope')

if not has_telescope then
  error('This plugins requires nvim-telescope/telescope.nvim')
end

local pickers = require('telescope.pickers')
local async_job_finder = require('telescope.finders.async_job_finder')
local utils = require('telescope._extensions.utils')
local distant = require('distant')
local distant_state = require('distant.state')

local function find_files(opts)
  local local_cwd = opts.cwd and vim.fn.expand(opts.cwd) or vim.loop.cwd()
  opts.cwd = local_cwd
  opts.max_results = opts.max_results or vim.o.lines or 100
  local remote_cwd = distant_state:get_cwd()
  local has_hg_root = utils.has_hg_root(remote_cwd)
  local cmd_bin = has_hg_root and 'myles' or 'find'
  local prompt_title = 'Distant[' .. cmd_bin .. ']: file name search'

  local function get_cmd(prompt)
    if has_hg_root then
      -- myles requires an hg repo to work.
      -- myles scales a lot better for repos with a lot of files like www
      -- and fbsource, that's why we prefer it.
      return {
        cmd_bin,
        '--list',
        '--limit',
        opts.max_results,
        '--client',
        'nvim',
        prompt,
      }
    end

    -- fallback to find
    -- some guidance on what flags to use at:
    -- https://github.com/nvim-telescope/telescope.nvim/blob/79644ab67731c7ba956c354bf0545282f34e10cc/lua/telescope/builtin/files.lua
    local cmd = {
      cmd_bin,
      '-type',
      'f',
    }
    local tokens = vim.tbl_flatten(vim.tbl_map(function(word)
      return { '-iname', '*' .. word .. '*' }
    end, vim.split(prompt, ' ')))
    return vim.list_extend(cmd, tokens)
  end

  if not opts.entry_maker then
    opts.entry_maker = function(value)
      -- Remove './' prefix if any
      value = value:gsub('^%./', '')
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

  local function get_finder_command(prompt)
    if not prompt or prompt == '' then
      return nil
    end
    return distant.wrap({ cmd = get_cmd(prompt) })
  end

  local finder_opts = vim.tbl_extend('force', {
    command_generator = get_finder_command,
  }, opts)

  pickers
      .new(opts, {
        prompt_title = prompt_title,
        finder = async_job_finder(finder_opts),
        previewer = utils.distant_buffer_previewer(opts),
      })
      :find()
end

return require('telescope').register_extension({
  exports = {
    distant_find_files = find_files,
  },
})
