local providers = require('slog.providers')
local config = require('slog.config')
local Text = require('slog.text')
local folds = require('slog.folds')
local b64 = require('slog.b64')
local util = require('slog.util')

---@class Renderer
local renderer = {}

local logs = {}
local tailer_job = nil

local signs = {}
local function update_signs()
  signs = config.options.signs
  if config.options.use_diagnostic_signs then
    local lsp_signs = require('slog.providers.diagnostic').get_signs()
    signs = vim.tbl_deep_extend('force', {}, signs, lsp_signs)
  end
end

local function get_sign_for_level(level)
  if level == 'info' then
    return signs.information, 'Information'
  elseif level == 'mustfix' or level == 'fatal' or level == 'error' then
    return signs.error, 'Error'
  elseif level == 'warning' then
    return signs.warning, 'Warning'
  end
  -- known so far: none, count
  return signs.hint, 'Hint'
end

local print_function_name = util.memoize(function(function_name)
  return string.gsub(function_name, 'base64json::<(.-)>', function(base64json)
    local json_str = b64.decode(base64json)
    local json = vim.json.decode(json_str)
    if type(json) == 'string' then
      return '"' .. json .. '"'
    elseif type(json) == 'table' then
      if json._special_text_key_DONT_USE then
        return json._special_text_key_DONT_USE
      elseif json[1] ~= nil then
        return 'vec[' .. #json .. ']'
      else
        return 'dict[' .. util.count(json) .. ']'
      end
    end
    return json_str
  end)
end)

local function render(view)
  local text = Text:new()
  view.items = {}

  -- reverse iteration over logs.
  -- This works great when you are just reading the logs, but the scroll
  -- behavior becomes of annoying especially when you are actively going
  -- through the log entries.
  -- for i = #logs, 1, -1 do
  --   renderer.render_log(view, text, logs[i])
  -- end
  for _, log in ipairs(logs) do
    renderer.render_log(view, text, log)
  end

  view:render(text)
end

function renderer.render(view, opts)
  renderer.start(view, opts)
  render(view)
end

function renderer.start(view, opts)
  if tailer_job ~= nil then
    return
  end

  update_signs()
  tailer_job = providers.get({ tier = '34833.od' }, function(log)
    local last_log = logs[#logs]
    if last_log ~= nil and log.title == last_log.title then
      last_log.count = last_log.count + 1
    else
      log.count = 1
      table.insert(logs, log)
    end
    render(view)
  end)
end

function renderer.close()
  logs = {}
  if tailer_job ~= nil then
    tailer_job:shutdown()
    tailer_job = nil
  end
end

function renderer.render_log(view, text, log)
  if log.error ~= nil then
    -- TODO render asking to report the issue back
    return
  end

  local key = log.attributes.date .. log.attributes.id
  view.items[text.lineNr + 1] = { key = key, is_top_level = true }

  text:render(' ')

  local fold_icon = folds.is_folded(key) and config.options.fold_closed or config.options.fold_open
  text:render(fold_icon, 'FoldIcon', ' ')

  local sign, type = get_sign_for_level(log.attributes.level)
  text:render(sign .. ' ', 'TroubleSign' .. type, { exact = true })

  if log.count > 1 then
    text:render(log.count .. 'x', 'Count', ' ')
  else
    text:render('   ')
  end

  text:render(os.date('%X %a %b', log.attributes.date), 'Date', ' ')

  -- TODO: Change to SlogTitle or something...
  local title_lines = vim.fn.split(log.title, '\n')
  text:render(title_lines[1], 'File', ' ')

  text:nl()

  if not folds.is_folded(key) then
    renderer.render_log_details(view, text, log)
  end
end

function renderer.render_log_details(view, text, log)

  local indent = ' │  '

  local title_lines = vim.fn.split(log.title, '\n')
  if #title_lines > 1 then
    for _, title_line in ipairs(title_lines) do
      view.items[text.lineNr + 1] = { title = log.title, is_extended_title = true }
      text:render(indent, 'Indent')
      text:render(title_line, 'Text')
      text:nl()
    end
  end

  for _, trace_item in ipairs(log.trace) do
    view.items[text.lineNr + 1] = trace_item

    text:render(indent, 'Indent')

    text:render(print_function_name(trace_item.functionName), 'Text', ' ')

    text:render(trace_item.fileName .. ':' .. trace_item.fileLine, 'Location', ' ')

    if trace_item.metadata ~= nil then
      local metadata_serialized = ''
      for mk, mv in pairs(trace_item.metadata) do
        metadata_serialized = metadata_serialized .. ' <' .. mk .. ':' .. mv .. '>'
      end
      text:render('with metadata' .. metadata_serialized, 'Metadata')
    end

    text:nl()
  end
end

return renderer
