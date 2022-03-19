local function tableGetFromEnd(tableInstance, index)
  return tableInstance[#tableInstance + 1 - index]
end

local function split(inputstr, sep)
  if sep == nil then
    sep = '%s'
  end
  local t = {}
  for str in string.gmatch(inputstr, '([^' .. sep .. ']+)') do
    table.insert(t, str)
  end
  return t
end

local BASE_URL = 'https://www.internalfb.com/code/'

local function getLineRange(mode)
  if mode == 'n' then
    return vim.fn.line('.')
  end
  local startLine = vim.fn.line("'<")
  local endLine = vim.fn.line("'>")
  if endLine == 0 then
    return startLine
  end
  return startLine .. '-' .. endLine
end

local function getRepoName()
  local remoteURL = vim.fn.trim(
    vim.fn.system({ 'git', 'remote', 'get-url', 'origin' })
  )
  local urlParts = split(remoteURL, '/')
  return tableGetFromEnd(urlParts, 2) .. '-' .. tableGetFromEnd(urlParts, 1)
end

local function getURL(mode)
  local repo = getRepoName()
  local gitPathPrefix = vim.fn.trim(
    vim.fn.system({ 'git', 'rev-parse', '--show-prefix' })
  )
  local lineRange = getLineRange(mode)
  local localPath = vim.fn.resolve(
    vim.fn.fnamemodify(vim.fn.expand('%'), ':~:.')
  )
  local url = BASE_URL
    .. repo
    .. '/'
    .. gitPathPrefix
    .. localPath
    .. '?lines='
    .. lineRange
  return url
end

return {
  copyURL = function(mode)
    local url = getURL(mode)
    vim.fn.setreg('+', url)
    print('copied ' .. url)
    return url
  end,
  openURL = function(mode)
    local url = getURL(mode)
    vim.cmd("silent !open '" .. url .. "'")
  end,
}
