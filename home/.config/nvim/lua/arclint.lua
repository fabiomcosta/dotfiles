local null_ls = require("null-ls")
local helpers = require("null-ls.helpers")
local null_utils = require("null-ls.utils")
local util = require("meta.util")

local Job = require('plenary.job')
local fnamemodify = vim.fn.fnamemodify

function stream_stdout(opts, on_stdout, on_exit)
  opts = vim.tbl_deep_extend('force', opts or {}, {
    on_stdout = function(err, data)
      vim.schedule(function()
        on_stdout(data)
      end)
    end,
    on_exit = on_exit,
  })
  Job:new(opts):start()
end

function get_filename(params)
  return params.temp_path or params.bufname
end

function runtime_condition(params)
  local filename = get_filename(params)

  -- Don't run diagnostics on HG commit messages.
  if filename:find("[.]hg/edit[-]tmp") then
    return false
  end

  local arcanist_root = util.arc.get_project_root(filename)
  if arcanist_root ~= nil then
    return true
  end

  return false
end

local parser = helpers.diagnostics.from_json({
  attributes = {
    row = "line",
    col = "char",
    source = "name",
    message = "description",
    severity = "severity",
    filename = "path",
  },
  severities = {
    advice = helpers.diagnostics.severities["information"],
  },
})

function generator_fn(params, done)
  local filename = get_filename(params)
  if params.err ~= nil then
    return done({
      line = 1,
      name = "arclint",
      description = params.err:gsub("^notice ", ""),
      severity = "advice",
      filename = filename,
    })
  end

  stream_stdout(
    {
      command = 'arc',
      args = {'linttool', 'ide', '--caller', 'neovim', filename},
      cwd = null_utils.get_root()
    },
    function(line)
      local diagnostic = util.parse_arclint_output(line)
      if diagnostic == nil then
        return vim.notify(
          'failed to decode arclint output: ' .. line,
          vim.log.levels.ERROR
        )
      end
      if diagnostic.type ~= 'issue' then
        return
      end

      if diagnostic.line == vim.NIL then
        diagnostic.line = 0
      elseif diagnostic.original == '' and diagnostic.replacement ~= '' then
        diagnostic.line = diagnostic.line - 1
      end
      diagnostic.name = 'arclint/' .. diagnostic.name

      -- There are some edge cases where the path is not actually correct, so
      -- we try our best to fix that in a "smart" way.
      if filename ~= diagnostic.path then
        if fnamemodify(filename, ':t') == fnamemodify(diagnostic.path, ':t') then
          diagnostic.path = filename
        end
      end

      done(parser({ output = { diagnostic } })[1])
    end,
    function()
      -- Stops the generator
      done(nil)
    end
  )
end

return {
  name = 'arclint',
  method = null_ls.methods.DIAGNOSTICS_ON_SAVE,
  filetypes = {},
  generator = {
    async_iterator = true,
    multiple_files = true,
    opts = {
      runtime_condition = runtime_condition
    },
    fn = generator_fn
  },
}
