local providers = require('slog.providers')
local config = require('slog.config')
local Text = require('slog.text')
local folds = require('slog.folds')
local b64 = require('slog.b64')
local util = require('slog.util')

local renderer = {}
local logs = {}
local tailer_job

local function get_sign_for_level(level)
  if level == 'info' then
    return config.options.signs.info, 'Info'
  elseif level == 'mustfix' then
    return config.options.signs.mustfix, 'Mustfix'
  elseif level == 'fatal' then
    return config.options.signs.fatal, 'Fatal'
  elseif level == 'warning' then
    return config.options.signs.warning, 'Warn'
  elseif level == 'slog' then
    return config.options.signs.slog, 'Slog'
  elseif level == 'count' then
    return config.options.signs.count, 'Count'
  end
  return config.options.signs.none, 'None'
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
  vim.fn.sign_unplace('*')

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

function renderer.render(view)
  renderer.start(view)
  render(view)
end

function renderer.start(view)
  if tailer_job ~= nil then
    return
  end

  tailer_job = providers.tail_logs(
    { tier = config.options.tier },
    function(log)
      local last_log = logs[#logs]
      if last_log ~= nil and log.title == last_log.title then
        last_log.count = last_log.count + 1
      else
        log.count = 1
        table.insert(logs, log)
      end
      render(view)
    end
  )
end

function renderer.clear(view)
  logs = {}
  view.items = {}
  render(view)
end

function renderer.close()
  logs = {}
  if tailer_job ~= nil then
    tailer_job:shutdown()
    tailer_job = nil
  end
end

function renderer.render_log(view, text, log)

  local line = text.lineNr + 1

  if log.error ~= nil then
    -- TODO render asking to report the issue back
    view.items[line] = {}
    local report_back_msg = log.error.metadata.isLikelySlogBug and
        ' Please report this back to https://fb.workplace.com/groups/1300890600405446' or ''
    text:render('TAILER ERROR: ' .. log.error.message .. report_back_msg)
    text:nl()
    return
  end

  if log.heartbeat == true then
    return
  end

  if config.options.filters.level and config.options.filters.level ~= log.attributes.level then
    return
  end

  local key = log.attributes.date .. log.attributes.id
  view.items[line] = { key = key, level = log.attributes.level, is_top_level = true }

  text:render(' ')

  local fold_icon = folds.is_folded(key) and config.options.fold_closed or config.options.fold_open
  text:render(fold_icon, 'FoldIcon', ' ')

  local sign, level = get_sign_for_level(log.attributes.level)

  text:render(os.date('%X %a %b', log.attributes.date), level .. 'Date')
  text:render(' ', level)

  text:render(sign .. ' ', level .. 'Sign')

  if log.count > 1 then
    local count = log.count > 9 and '9+' or log.count .. 'x'
    text:render(count, level .. 'Count')
    text:render(' ', level)
  else
    text:render('   ', level)
  end

  local title_lines = vim.fn.split(log.title, '\n')
  text:render(title_lines[1], level .. 'Title', ' ')

  vim.fn.sign_place(line, '', 'Slog' .. level .. 'Sign', view.buf, { lnum = line })
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
