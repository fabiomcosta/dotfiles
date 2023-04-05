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

local previewers = require('telescope.previewers')
local finders = require('telescope.finders')
local make_entry = require('telescope.make_entry')
local pickers = require('telescope.pickers')
local sorters = require('telescope.sorters')
local distant = require('distant')
local filetype = require('plenary.filetype')

local ns_previewer = vim.api.nvim_create_namespace('telescope.previewers')

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

-- vim.tbl_map doesn't provide the key to the map function :/
local function tbl_map(table, map_fn)
  local mapped_table = {}
  for k, v in pairs(table) do
    mapped_table[k] = map_fn(v, k)
  end
  return mapped_table
end

local function url_remove_protocol(url)
  return string.gsub(url, '^%w+://', '')
end

local function get_start_text(opts)
  -- range == 2 means both '< and '> were provided, which we need.
  if opts.range == 2 and opts.start_line == opts.end_line then
    local _, lnum, col1 = unpack(vim.fn.getpos("'<"))
    local col2 = vim.fn.getpos("'>")[3]
    return vim.fn.getline(lnum):sub(col1, col2)
  end
end

-- TODO make this async
local function system(opts)
  local output = vim.fn.system(distant.wrap(opts))
  if vim.v.shell_error ~= 0 then
    return nil
  end
  return vim.trim(output)
end

local function set_buffer_text(bufnr, text)
  vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, text)
end

local function attach_ts_parser(bufnr, path)
  local is_ts_loaded, ts_configs = pcall(require, 'nvim-treesitter.configs')
  if not is_ts_loaded then
    return
  end
  local ts_parsers = require('nvim-treesitter.parsers')
  local ft = filetype.detect_from_extension(path)
  local lang = ts_parsers.ft_to_lang(ft)
  -- errrr...
  lang = lang == 'php' and 'hack' or lang
  if not ts_configs.is_enabled('highlight', lang, bufnr) then
    return false
  end
  vim.treesitter.highlighter.new(ts_parsers.get_parser(bufnr, lang))
end

local function file_maker(filepath, bufnr, opts)
  opts = opts or {}
  if opts.bufname ~= filepath then
    if not vim.api.nvim_buf_is_valid(bufnr) then
      return
    end
    local remote_path = url_remove_protocol(filepath)
    distant.fn.read_file_text(
      { path = remote_path, timeout = 2000 },
      function(err, file_content)
        if err then
          pcall(
            set_buffer_text,
            bufnr,
            { ('ERROR: reading the currently selected file.\n%s'):format(err) }
          )
          return
        end
        if string.len(file_content) > 100000 then
          pcall(
            set_buffer_text,
            bufnr,
            { 'ERROR: File has more than 100k characters.' }
          )
          return
        end
        local ok =
          pcall(set_buffer_text, bufnr, vim.split(file_content, '[\r]?\n'))
        if not ok then
          pcall(set_buffer_text, bufnr, {
            "ERROR: Couldn't set Previewer's buffer content to the selected file.",
          })
          return
        end

        attach_ts_parser(bufnr, remote_path)

        if opts.callback then
          opts.callback(bufnr)
        end
      end
    )
  else
    if opts.callback then
      opts.callback(bufnr)
    end
  end
end

local function previewer(opts)
  opts = opts or {}

  local function jump_to_line(self, bufnr, lnum)
    pcall(vim.api.nvim_buf_clear_namespace, bufnr, ns_previewer, 0, -1)
    if lnum and lnum > 0 then
      pcall(
        vim.api.nvim_buf_add_highlight,
        bufnr,
        ns_previewer,
        'TelescopePreviewLine',
        lnum - 1,
        0,
        -1
      )
      pcall(vim.api.nvim_win_set_cursor, self.state.winid, { lnum, 0 })
      vim.api.nvim_buf_call(bufnr, function()
        vim.cmd('norm! zz')
      end)
    end
  end

  return previewers.new_buffer_previewer({
    title = 'BigGrep Preview',
    get_buffer_by_name = function(_, entry)
      return entry.path
    end,
    define_preview = function(self, entry)
      file_maker(entry.path, self.state.bufnr, {
        bufname = self.state.bufname,
        callback = function(bufnr)
          jump_to_line(self, bufnr, entry.lnum)
        end,
      })
    end,
  })
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

    local project_root = system({ cmd = { 'hg', 'root' }, cwd = remote_cwd })
    if project_root == nil then
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
        -- this is used when pressing enter to open the distant file
        entry.path = 'distant://' .. remote_cwd .. '/' .. entry.filename
        return entry
      end
    end

    -- local previewer_opts = vim.tbl_extend('force', {
    --   get_command = function(entry, status)
    --     local height = vim.api.nvim_win_get_height(status.preview_win)
    --     local lnum = entry.lnum or 0
    --     local context = math.floor(height / 2)
    --     local start = math.max(0, lnum - context)
    --     return distant.wrap({
    --       shell = vim.fn.json_encode(
    --         ('less -P "" -RS +%s %s'):format(
    --           start,
    --           url_remove_protocol(entry.path)
    --         )
    --       ),
    --     })
    --   end,
    -- }, opts)

    pickers
      .new(opts, {
        prompt_title = prompt_title,
        finder = finders.new_job(
          get_finder_command,
          opts.entry_maker,
          opts.max_results,
          opts.cwd
        ),
        previewer = previewer(opts),
        -- previewer = previewers.new_termopen_previewer(previewer_opts),
        sorter = sorters.highlighter_only(opts),
        default_text = get_start_text(opts),
      })
      :find()
  end
end

return require('telescope').register_extension({
  exports = tbl_map(BIGGREP_ENGINE, function(_, engine_prefix)
    return make_biggrep(engine_prefix)
  end),
})
