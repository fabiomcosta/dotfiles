local filetype = require('plenary.filetype')
local previewers = require('telescope.previewers')
local distant = require('distant')

local ns_previewer = vim.api.nvim_create_namespace('telescope.previewers')

local M = {}

local function set_buffer_text(bufnr, text)
  vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, text)
end

-- TODO make this async
local function system(opts)
  local output = vim.fn.system(distant.wrap(opts))
  if vim.v.shell_error ~= 0 then
    return nil
  end
  return vim.trim(output)
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
    pcall(set_buffer_text, bufnr, { 'loading file...' })

    local remote_path = M.url_remove_protocol(filepath)

    -- TODO improve this callback hell with an async lib
    distant.fn.spawn_wait(
      { cmd = ('file --mime-type -b "%s"'):format(remote_path) },
      vim.schedule_wrap(function(file_error, output)
        if file_error then
          pcall(set_buffer_text, bufnr, {
            ('ERROR: while detecting if the selected file is a text file.\n%s'):format(
              file_error
            ),
          })
          return
        end
        local mime_type = string.char(unpack(output.stdout))
        mime_type = vim.split(mime_type, '/')[1]
        if mime_type ~= 'text' then
          pcall(set_buffer_text, bufnr, {
            ('INFO: there is no preview available because this is not a text file. Detected mime-type: %s'):format(
              mime_type
            ),
          })
          return
        end

        distant.fn.read_file_text(
          { path = remote_path, timeout = 2000 },
          function(read_error, file_content)
            if read_error then
              pcall(set_buffer_text, bufnr, {
                ("ERROR: reading the currently selected file. It's likely too big.\n%s"):format(
                  read_error
                ),
              })
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
      end)
    )
  else
    if opts.callback then
      opts.callback(bufnr)
    end
  end
end

-- vim.tbl_map doesn't provide the key to the map function :/
function M.tbl_map(table, map_fn)
  local mapped_table = {}
  for k, v in pairs(table) do
    mapped_table[k] = map_fn(v, k)
  end
  return mapped_table
end

function M.url_remove_protocol(url)
  return string.gsub(url, '^%w+://', '')
end

function M.has_hg_root(remote_cwd)
  return system({ cmd = { 'hg', 'root' }, cwd = remote_cwd }) ~= nil
end

function M.distant_buffer_previewer(opts)
  opts = opts or {}

  local function jump_to_line(self, bufnr, lnum)
    if lnum and lnum > 0 then
      pcall(vim.api.nvim_buf_clear_namespace, bufnr, ns_previewer, 0, -1)
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
    title = 'Preview file',
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

return M
