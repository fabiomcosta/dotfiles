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

local ui_parts = {
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
  }
  -- 'count',
}

function M.setup()
  for k, v in pairs(links) do
    vim.api.nvim_command("hi def link Slog" .. k .. " " .. v)
  end
  for _, log_level in pairs(log_levels) do
    local slog_hi_name = "Slog" .. log_level.name
    vim.api.nvim_command("hi " .. slog_hi_name .. " guifg=" .. log_level.fg .. " guibg=" .. log_level.bg)
    for _, part in pairs(ui_parts) do
      if part.fg or part.bg then
        local fg = part.fg or log_level.fg
        local bg = part.bg or log_level.bg
        vim.api.nvim_command("hi " .. slog_hi_name .. part.name .. " guifg=" .. fg .. " guibg=" .. bg)
      else
        vim.api.nvim_command("hi def link " .. slog_hi_name .. part.name .. " " .. slog_hi_name)
      end
    end
  end
end

M.setup()

return M
