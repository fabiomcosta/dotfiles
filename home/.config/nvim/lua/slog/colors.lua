local preview_sign = require('slog.preview_sign')

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

local log_ui = {
  sign = {
    name = 'Sign'
  },
  count = {
    name = 'Count',
  },
  date = {
    name = 'Date',
  },
  title = {
    name = 'Title',
  },
  location = {
    name = 'Location',
  },
  metadata = {
    name = 'Metadata',
  },
}

local support_panel_ui = {
  connection_success = {
    name = 'ConnectionSuccess',
    fg = '#3EBD5F',
  },
  connection_error = {
    name = 'ConnectionError',
    fg = '#f8a5a5',
  }
}

local log_levels = {
  slog = {
    name = 'Slog',
    fg = '#F0C79C',
    bg = '#696055'
  },
  warning = {
    name = 'Warn',
    fg = '#F6E8AD',
    bg = '#484435'
  },
  info = {
    name = 'Info',
    fg = '#B3DCFC',
    bg = '#373F48'
  },
  mustfix = {
    name = 'Mustfix',
    fg = '#ECA9A7',
    bg = '#4C363B',
  },
  fatal = {
    name = 'Fatal',
    fg = '#FFFFFF',
    bg = '#4E2A2F',
  },
  none = {
    name = 'None',
    fg = '#FFFFFF',
    bg = '#292D33',
  },
  count = {
    name = 'None',
    fg = '#FFFFFF',
    bg = '#292D33',
  }
}

function M.setup()
  preview_sign.define()
  for k, v in pairs(links) do
    vim.api.nvim_command("hi def link Slog" .. k .. " " .. v)
  end
  for _, log_level in pairs(log_levels) do
    local slog_hi_name = "Slog" .. log_level.name
    vim.api.nvim_command("hi " .. slog_hi_name .. " guifg=" .. log_level.fg)
    vim.api.nvim_command("hi " .. slog_hi_name .. "Bg guibg=" .. log_level.bg)
    vim.fn.sign_define(slog_hi_name .. 'Sign', { linehl = slog_hi_name .. 'Bg' })
    for _, ui_part in pairs(log_ui) do
      vim.api.nvim_command("hi def link " .. slog_hi_name .. ui_part.name .. " " .. slog_hi_name)
    end
  end
  for _, ui_part in pairs(support_panel_ui) do
    vim.api.nvim_command("hi Slog" .. ui_part.name .. " guifg=" .. ui_part.fg)
  end
end

return M
