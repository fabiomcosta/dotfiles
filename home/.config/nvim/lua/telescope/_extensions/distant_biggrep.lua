-- @lint-ignore-every LUA_LUAJIT
-- Here is a little story about why there is so much code on this file...
-- Telescope's buffer previewers have the assumption that the files are on the
-- local file system, and don't provide any option to change that ATM.
-- File highlightning is also kind of tricky to get with cli tools and depends
-- on having them installed on the server, which is not ideal.
--
-- In order to work around these, I had to create a bare bones previewer
-- that reads files using distant.fn.read_file_text and highlights the text
-- using the localy installed treesitter parsers.
local has_telescope, _ = pcall(require, 'telescope')

if not has_telescope then
  error('This plugins requires nvim-telescope/telescope.nvim')
end

local finders = require('telescope.finders')
local make_entry = require('telescope.make_entry')
local pickers = require('telescope.pickers')
local sorters = require('telescope.sorters')
local distant = require('distant')
local utils = require('telescope._extensions.utils')

-- TODO this is an option or path of a distant-project plugin setup
local distant_project = {
  config = {
    cwd = '/home/fabs/www',
  },
}

local BIGGREP_ENGINE = {
  s = 'Substring',
  r = 'Regex',
  f = 'Filename',
}

local function get_start_text(opts)
  -- range == 2 means both '< and '> were provided, which we need.
  if opts.range == 2 and opts.start_line == opts.end_line then
    local _, lnum, col1 = unpack(vim.fn.getpos("'<"))
    local col2 = vim.fn.getpos("'>")[3]
    return vim.fn.getline(lnum):sub(col1, col2)
  end
end

-- Special keys:
--   opts.files_regex -- restricts bg search to files matching this pattern
--   opts.exclude -- exclude filenames matching this pattern
--   opts.project -- scope results to codehub project
--   opts.ignore_case -- run a case insensitive search
local function make_biggrep(bg_suffix)
  local prompt_title = ('BigGrep %s Search'):format(BIGGREP_ENGINE[bg_suffix])

  return function(opts)
    local local_cwd = opts.cwd and vim.fn.expand(opts.cwd) or vim.loop.cwd()
    opts.cwd = local_cwd
    opts.max_results = opts.max_results or vim.o.lines or 100

    local remote_cwd = distant_project.config.cwd

    -- the biggrep commands need to run from an hg repo folder
    if utils.has_hg_root(remote_cwd) == nil then
      vim.notify('No hg root found for: ' .. remote_cwd, vim.log.levels.ERROR)
      return nil
    end

    local function get_finder_command(prompt)
      if not prompt or prompt == '' then
        return nil
      end

      local cmd = {
        'bg' .. bg_suffix,
        '-n',
        opts.max_results,
        '-s',
      }

      if opts.files_regex then
        table.insert(cmd, '-f')
        table.insert(cmd, opts.files_regex)
      end

      if opts.exclude then
        table.insert(cmd, '--exclude')
        table.insert(cmd, opts.exclude)
      end

      if opts.project then
        table.insert(cmd, '-p')
        table.insert(cmd, opts.project)
      end

      if opts.ignore_case then
        table.insert(cmd, '--ignore-case')
      end

      table.insert(cmd, vim.fn.json_encode(prompt))

      return distant.wrap({ cmd = cmd, cwd = remote_cwd })
    end

    if not opts.entry_maker then
      local vimgrep_entry_maker = make_entry.gen_from_vimgrep(opts)
      opts.entry_maker = function(grep_output_line)
        local entry = vimgrep_entry_maker(grep_output_line)
        -- this is the path used when selecting a file
        entry.path = 'distant://' .. remote_cwd .. '/' .. entry.filename
        return entry
      end
    end

    pickers
      .new(opts, {
        prompt_title = prompt_title,
        finder = finders.new_job(
          get_finder_command,
          opts.entry_maker,
          opts.max_results,
          opts.cwd
        ),
        previewer = utils.distant_buffer_previewer(opts),
        sorter = sorters.highlighter_only(opts),
        default_text = get_start_text(opts),
      })
      :find()
  end
end

return require('telescope').register_extension({
  exports = utils.tbl_map(BIGGREP_ENGINE, function(_, engine_prefix)
    return make_biggrep(engine_prefix)
  end),
})
