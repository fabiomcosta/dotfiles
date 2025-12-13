local utils = require('utils')

local function get_keywords()
  local keywords = ''
  for _, value in pairs(vim.opt.iskeyword:get()) do
    if value == '@' then
      keywords = keywords .. '%w'
    elseif value == '@-@' then
      -- Since @ matches a-zA-Z, to match the @ char @-@ can be used
      keywords = keywords .. '@'
    elseif #value == 1 then
      keywords = keywords .. value
    elseif value ~= '^' and value:sub(1, 1) == '^' then
      -- Ignoring negated ranges
    else
      local start, _end = string.match(value, '([^-]+)-([^-]+)')
      if start ~= nil then
        local nstart = tonumber(start)
        if nstart ~= nil then
          start = string.char(nstart)
        end
        local nend = tonumber(_end)
        if nend ~= nil then
          _end = string.char(nend)
        end
        keywords = keywords .. start .. '-' .. _end
      else
        error('Unexpected value part of keywords option: ' .. value)
      end
    end
  end
  return keywords
end

-- This is a very specific method to this function.
-- Returns any individual character that are contained inside the iskeyword
-- option.
local function get_non_range_keywords()
  local keywords = ''
  for _, value in pairs(vim.opt.iskeyword:get()) do
    if value == '@-@' then
      -- @-@ represents the @ character
      keywords = keywords .. '@'
    elseif value ~= '@' and #value == 1 then
      -- @ represents all alphanumerics and we don't want to add it as a
      -- matching character, but anything else is good.
      keywords = keywords .. value
    end
  end
  return keywords
end

-- Escapes some characters to be used in lua regexes
local function regex_escape(str)
  return str
      :gsub('%$', '%%$')
      :gsub('%?', '%%?')
      :gsub('%.', '%%.')
      :gsub('%^', '%%^')
      :gsub('%(', '%%(')
      :gsub('%)', '%%)')
      :gsub('%[', '%%[')
      :gsub('%]', '%%]')
end

local function is_snake_case(word)
  local keywords = regex_escape(get_non_range_keywords())
  return string.find(word, '_')
      and #word:gsub('[_%l%d' .. keywords .. ']+', '') == 0
end

local function is_upper_case(word)
  local keywords = regex_escape(get_non_range_keywords())
  return string.find(word, '_')
      and #word:gsub('[_%u%d' .. keywords .. ']+', '') == 0
end

local function is_kebab_case(word)
  local keywords = regex_escape(get_non_range_keywords())
  return string.find(word, '-')
      and #word:gsub('[-%l%d' .. keywords .. ']+', '') == 0
end

local function is_camel_case(word)
  local keywords = regex_escape(get_non_range_keywords())
  local word_without_special_keywords = word:gsub('[' .. keywords .. ']+', '')
  return #word:gsub('[%l%u%d' .. keywords .. ']+', '') == 0
      and #word:gsub('%l+', '') > 0
      and word_without_special_keywords:match('^%l')
end

local function is_pascal_case(word)
  local keywords = regex_escape(get_non_range_keywords())
  local word_without_special_keywords = word:gsub('[' .. keywords .. ']+', '')
  return #word:gsub('[%l%u%d' .. keywords .. ']+', '') == 0
      and #word:gsub('%l+', '') > 0
      and word_without_special_keywords:match('^%u')
end

local function to_snake_case(word)
  -- if snake_case or UPPER_CASE
  if string.find(word, '_') then
    return word:lower()
  end
  -- if kebab-case (lower and upper)
  if string.find(word, '-') then
    return word:gsub('-', '_'):lower()
  end
  local keywords = regex_escape(get_non_range_keywords())
  word = word:gsub('^[' .. keywords .. ']?%u', string.lower)
  word = word:gsub('(%u)', function(c)
    return '_' .. c:lower()
  end)
  return word
end

local function to_upper_case(word)
  return to_snake_case(word):upper()
end

local function to_camel_case(word)
  word = to_snake_case(word):gsub('_(%l)', function(c)
    return c:upper()
  end)
  return word
end

local function to_kebab_case(word)
  word = to_snake_case(word):gsub('_', '-')
  return word
end

local function to_pascal_case(word)
  local keywords = regex_escape(get_non_range_keywords())
  word = to_camel_case(word):gsub('^[' .. keywords .. ']?%l', string.upper)
  return word
end

local function cycle_case(word)
  if is_snake_case(word) then
    return to_upper_case(word)
  end
  if is_upper_case(word) then
    return to_camel_case(word)
  end

  if is_camel_case(word) then
    local ft_supports_kebab_case =
        utils.tbl_contains(vim.opt.iskeyword:get(), '-')
    if ft_supports_kebab_case then
      return to_kebab_case(word)
    else
      return to_pascal_case(word)
    end
  end

  if is_kebab_case(word) then
    return to_pascal_case(word)
  end
  if is_pascal_case(word) then
    return to_snake_case(word)
  end
end

local function replace_word_under_cursor(transformer)
  local bufnr = 0
  local winnr = 0
  local cursorword = vim.fn.expand('<cword>')
  local row, col = unpack(vim.api.nvim_win_get_cursor(winnr))
  local line = vim.api.nvim_get_current_line()

  local keywords = '[' .. regex_escape(get_keywords()) .. ']'

  -- +1 to make it 1 indexed and +1 to also check the current char under
  -- the cursor.
  local start_col = col + 2
  local end_col = col + 1

  while
    start_col > 0 and line:sub(start_col - 1, start_col - 1):match(keywords)
  do
    start_col = start_col - 1
  end

  while
    end_col < #line and line:sub(end_col + 1, end_col + 1):match(keywords)
  do
    end_col = end_col + 1
  end

  local detected_cursorword = line:sub(start_col, end_col)
  if cursorword ~= detected_cursorword then
    error(
      '"' .. cursorword .. '" did not match "' .. detected_cursorword .. '"'
    )
  end

  vim.api.nvim_buf_set_text(
    bufnr,
    row - 1,
    start_col - 1,
    row - 1,
    end_col,
    { transformer(cursorword) }
  )
end

local function apply()
  replace_word_under_cursor(cycle_case)
end

return {
  apply = apply,
}
