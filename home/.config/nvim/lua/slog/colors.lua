local util = require('slog.util')

local M = {}

local links = {
  TextError = "SlogText",
  TextWarning = "SlogText",
  TextInformation = "SlogText",
  TextHint = "SlogText",
  Text = "Normal",
  File = "Directory",
  Source = "Comment",
  Code = "Comment",
  Location = "LineNr",
  FoldIcon = "CursorLineNr",
  Normal = "Normal",
  Count = "TabLineSel",
  Preview = "Search",
  Indent = "LineNr",
  SignOther = "SlogSignInformation",
}

function M.setup()
  for k, v in pairs(links) do
    vim.api.nvim_command("hi def link Slog" .. k .. " " .. v)
  end
  for _, severity in pairs(util.severity) do
    vim.api.nvim_command("hi def link Slog" .. severity .. " " .. util.get_severity_label(severity))
    vim.api.nvim_command("hi def link SlogSign" .. severity .. " " .. util.get_severity_label(severity, "Sign"))
  end
end

M.setup()

return M
