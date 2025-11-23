local config = require('slog.config')
local Text = require('slog.text')
local folds = require('slog.folds')
local util = require('slog.util')
local tailer = require('slog.tailer')
local stringify = require('slog.stringify')

local renderer = {}
local logs = {}

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

local function render(view)
  if not view:is_valid() then
    return
  end

  view.items = {}
  vim.fn.sign_unplace('*', { buffer = view.buf })

  local text = Text:new()
  for _, log in ipairs(logs) do
    renderer.render_log(view, text, log)
  end
  view:render(text)

  view.filter_panel:close()
  if config.options.filters.level ~= nil then
    local t = Text:new()
    t:render(' showing ' .. text.lineNr .. ' out of ' .. #logs .. ' ')
    t:nl()
    view.filter_panel:render(t)
    view.filter_panel:open()
  end
end

function renderer.render(view)
  renderer.start(view)
  render(view)
end

function renderer.start(view)
  tailer.start({ tier = config.options.tier }, function(log)
    if log.timeout == true then
      util.debug('timeout')
      view:set_is_likely_connected(false)
      return
    end

    view:set_is_likely_connected(true)

    if log.heartbeat == true then
      util.debug('heartbeat')
      return
    end

    local last_log = logs[#logs]
    -- groups similar logs into the same line
    if last_log ~= nil and log.title == last_log.title then
      log.count = last_log.count + 1
      logs[#logs] = log
    else
      log.count = 1
      table.insert(logs, log)
    end
    render(view)
  end)
end

function renderer.clear(view)
  logs = {}
  view.items = {}
  render(view)
end

function renderer.close()
  logs = {}
  tailer.shutdown()
end

local function date_adapt_to_timezone(date)
  if vim.env.TZ == nil then
    return date
  end
  local tz_offset = util.date_offset(date)
  local local_ts = date + (tz_offset * (60 * 60))
  return os.date('%X %a %b', local_ts)
end

local function should_render_log(log)
  if config.options.filters.log == nil then
    return true
  end
  return config.options.filters.log(log)
end

function renderer.render_log(view, text, log)
  local line = text.lineNr + 1

  if log.error ~= nil then
    view.items[line] = {}
    local report_back_msg = log.error.metadata.isLikelySlogBug
        and ' Please report this back to https://fb.workplace.com/groups/1300890600405446'
        or ''
    text:render('TAILER ERROR: ' .. log.error.message .. report_back_msg)
    text:nl()
    return
  end

  if
      config.options.filters.level
      and config.options.filters.level ~= log.attributes.level
  then
    return
  end

  if not should_render_log(log) then
    return
  end

  local key = log.attributes.date .. log.attributes.id
  view.items[line] = {
    key = key,
    level = log.attributes.level,
    is_top_level = true,
    text = log.title,
    log = log,
  }

  text:render(' ')

  local fold_icon = folds.is_folded(key) and config.options.fold_closed
      or config.options.fold_open
  text:render(fold_icon, 'FoldIcon', ' ')

  local sign, level = get_sign_for_level(log.attributes.level)

  text:render(date_adapt_to_timezone(log.attributes.date), level .. 'Date')
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

  vim.fn.sign_place(
    line,
    '',
    'Slog' .. level .. 'Sign',
    view.buf,
    { lnum = line }
  )
  text:nl()

  if not folds.is_folded(key) then
    renderer.render_log_details(view, text, log)
  end
end

local function should_render_trace(trace)
  if config.options.filters.trace == nil then
    return true
  end
  return config.options.filters.trace(trace)
end

function renderer.render_log_details(view, text, log)
  local indent = ' │  '

  local title_lines = vim.fn.split(log.title, '\n')
  if #title_lines > 1 then
    for _, title_line in ipairs(title_lines) do
      view.items[text.lineNr + 1] =
      { title = log.title, is_extended_title = true, text = log.title }
      text:render(indent, 'Indent')
      text:render(title_line, 'Text')
      text:nl()
    end
    text:render(indent, 'Indent')
    text:nl()
  end

  for _, trace_item in ipairs(log.trace) do
    if should_render_trace(trace_item) then
      view.items[text.lineNr + 1] = trace_item

      text:render(indent, 'Indent')

      local function_name = stringify.function_name(trace_item.functionName)
      text:render(function_name, 'Text', ' ')

      local file_location = stringify.file(trace_item)
      if file_location ~= nil then
        text:render(file_location, 'Location', ' ')
      end

      local metadata = stringify.metadata(trace_item)
      if metadata ~= nil then
        metadata = 'with metadata' .. metadata
        text:render(metadata, 'Metadata')
      end

      trace_item.text =
          vim.fn.join({ function_name, file_location, metadata }, ' ')

      text:nl()
    end
  end
end

return renderer
