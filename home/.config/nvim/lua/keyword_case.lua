local utils = require('utils')

local function get_keywords()
  local keywords = ''
  for _, value in pairs(vim.opt.iskeyword:get()) do
    -- This might not be the best heuristic for this, but works for now.
    if #value == 1 then
      keywords = keywords .. value
    end
  end
  return keywords
end

-- Escapes characters to be used in lua regexes
local function regex_escape(str)
  return vim.fn.escape(str, '^$.*?[]~-/\\')
end

local function is_snake_case(word)
  local keywords = regex_escape(get_keywords())
  return string.find(word, '_')
    and #word:gsub('[_%l%d' .. keywords .. ']+', '') == 0
end

local function is_upper_case(word)
  local keywords = regex_escape(get_keywords())
  return string.find(word, '_')
    and #word:gsub('[_%u%d' .. keywords .. ']+', '') == 0
end

local function is_kebab_case(word)
  local keywords = regex_escape(get_keywords())
  return string.find(word, '-')
    and #word:gsub('[-%l%d' .. keywords .. ']+', '') == 0
end

local function is_camel_case(word)
  local keywords = regex_escape(get_keywords())
  local word_without_special_keywords = word:gsub('[' .. keywords .. ']+', '')
  return #word:gsub('[%l%u%d' .. keywords .. ']+', '') == 0
    and #word:gsub('%l+', '') > 0
    and word_without_special_keywords:match('^%l')
end

local function is_pascal_case(word)
  local keywords = regex_escape(get_keywords())
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
  local keywords = regex_escape(get_keywords())
  word = word:gsub('^[' .. keywords .. ']?%u', string.lower)
  return word:gsub('(%u)', function(c)
    return '_' .. c:lower()
  end)
end

local function to_upper_case(word)
  return to_snake_case(word):upper()
end

local function to_camel_case(word)
  return to_snake_case(word):gsub('_(%l)', function(c)
    return c:upper()
  end)
end

local function to_kebab_case(word)
  return to_snake_case(word):gsub('_', '-')
end

local function to_pascal_case(word)
  local keywords = regex_escape(get_keywords())
  return to_camel_case(word):gsub('^[' .. keywords .. ']?%l', string.upper)
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

local function apply()
  local cursorword = vim.fn.expand('<cword>')
  vim.cmd('normal! diwi' .. cycle_case(cursorword))
end

return {
  setup = function()
    vim.api.nvim_create_user_command('CodeCycleCase', apply, {})
  end,
  apply = apply,
}
