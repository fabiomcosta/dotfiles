
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

local BASE_URL = 'https://www.internalfb.com/code/'

local function _getURL(mode)
  -- TODO: maybe we can ge this from the remote URL?
  local repo = 'whatsapp-wajs'
  local gitPathPrefix = vim.fn.trim(vim.fn.system({'git', 'rev-parse', '--show-prefix'}))
  local lineRange = getLineRange(mode)
  -- echo lineRange
  -- echo 'mode ' . mode()
  local localPath = vim.fn.resolve(vim.fn.fnamemodify(vim.fn.expand('%'), ':~:.'))
  local url = BASE_URL .. repo .. '/' .. gitPathPrefix .. localPath .. '?lines=' .. lineRange
  return url
end

return {
  copyURL = function(mode)
    local url = _getURL(mode)
    vim.fn.setreg('+', url)
    print('copied ' .. url)
    return url
  end,
  openURL = function(mode)
    local url = _getURL(mode)
    vim.cmd("silent !open '" .. url .. "'")
  end
}
