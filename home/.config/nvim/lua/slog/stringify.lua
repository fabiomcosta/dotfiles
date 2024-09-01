local b64 = require('slog.b64')
local util = require('slog.util')

local stringify = {}

local function tbl_remove_key(tbl, key)
  local value = tbl[key]
  tbl[key] = nil
  return value
end

stringify.function_name = util.memoize(function(function_name)
  return string.gsub(function_name, 'base64json::<(.-)>', function(base64json)
    local json_str = b64.decode(base64json)
    local ok, json = pcall(vim.json.decode, json_str)
    if not ok then
      util.debug([[Couldn't decode ]] .. json_str .. [[ as json.]])
      return json_str
    end
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

function stringify.file(trace_item)
  local filename = trace_item.fileName
  if filename == nil or trace_item.fileLine == nil then
    return nil
  end

  -- trying to create a relative path, which will be less characters to show
  filename = util.get_relative_filename(filename)
  return filename .. ':' .. trace_item.fileLine
end

function stringify.metadata(trace_item)
  if trace_item.metadata == nil then
    return nil
  end
  local metadata = ''
  for mk, mv in pairs(trace_item.metadata) do
    metadata = metadata .. ' '
    metadata = metadata .. '<' .. mk .. ':' .. mv .. '>'
  end
  return metadata
end

function stringify.log(log)
  local str = ''

  local attributes = vim.tbl_deep_extend('force', {}, log.attributes)

  local date = tbl_remove_key(attributes, 'date')
  str = str .. '[' .. os.date('%a %b %d %X %Y', date) .. ']'
  str = str .. ' '
  str = str .. '[' .. tbl_remove_key(attributes, 'service') .. ']'
  str = str .. ' '
  str = str .. '[' .. tbl_remove_key(attributes, 'id') .. ']'

  for mk, mv in pairs(attributes) do
    str = str .. ' '
    str = str .. '<' .. mk .. ':' .. mv .. '>'
  end

  str = str .. ' '
  str = str .. log.title

  str = str .. '\n'

  for mk, mv in pairs(log.properties) do
    str = str .. '(' .. mk .. ': ' .. mv .. ')'
    str = str .. '\n'
  end

  str = str .. 'trace'
  str = str .. '\n'

  for index, trace_item in ipairs(log.trace) do
    str = str .. '    '
    str = str .. '#' .. (index - 1)

    str = str .. ' '
    str = str .. stringify.function_name(trace_item.functionName)

    local file = stringify.file(trace_item)
    if file ~= nil then
      str = str .. ' '
      str = str .. '[' .. file .. ']'
    end

    local metadata = stringify.metadata(trace_item)
    if metadata ~= nil then
      str = str .. ' with metadata'
      str = str .. metadata
    end

    str = str .. '\n'
  end

  return str
end

return stringify
