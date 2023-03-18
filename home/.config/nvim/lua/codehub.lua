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

local function isMacos()
  local uname = vim.fn.trim(vim.fn.system('uname'))
  if vim.v.shell_error == 1 then
    return false
  end
  return uname == "Darwin"
end

local function isRemoteSession()
  return (vim.env.SSH_CLIENT or vim.env.SSH_TTY) ~= nil
end

local function possiblyHasOpenerSocketFile()
  -- The location of this file depends on some configuration,
  -- but this is the default value and should work in most cases.
  return vim.fn.filereadable(vim.fn.expand('~/.opener.sock')) > 0
end

local function canUseOpen()
  if possiblyHasOpenerSocketFile() then
    return true
  end
  return isMacos() and not isRemoteSession()
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

local function getURLForGitRepo(mode)
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

local metaCmdsStatus, metaCmds = pcall(require, 'meta.cmds')
local metaUtilStatus, metaUtil = pcall(require, 'meta.util')

local function getURL(mode)
  if metaCmdsStatus and metaUtilStatus then
    if metaUtil.hg.get_root_path() ~= nil then
      if mode == 'n' then
        return metaCmds.get_codehub_link()
      else
        return metaCmds.get_codehub_link(2, vim.fn.line("'<"), vim.fn.line("'>"))
      end
    end
  end
  return getURLForGitRepo(mode)
end

local function copyToRegister(url)
  vim.fn.setreg('+', url)
  if vim.api.nvim_get_commands({}).OSCYankRegister then
    vim.cmd([[silent OSCYankRegister +]])
  elseif vim.api.nvim_get_commands({}).OSCYankReg then
    vim.cmd([[silent OSCYankReg +]])
  else
    local oscLoaded, osc52 = pcall(require, 'osc52')
    if oscLoaded then
      osc52.copy_register('+')
    end
  end
  print('copied ' .. url)
end

return {
  copyURL = function(mode)
    local url = getURL(mode)
    copyToRegister(url)
  end,
  openURL = function(mode)
    local url = getURL(mode)
    if canUseOpen() then
      vim.cmd("silent !open '" .. url .. "'")
    else
      copyToRegister(url)
    end
  end,
}
