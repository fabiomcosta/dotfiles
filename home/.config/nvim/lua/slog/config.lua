local M = {}

M.namespace = vim.api.nvim_create_namespace("slog")

local defaults = {
  debug = false,
  position = "bottom", -- position of the list can be: bottom, top, left, right
  height = 20, -- height of the trouble list when position is top or bottom
  width = 50, -- width of the list when position is left or right
  fold_open = "", -- icon used for open folds
  fold_closed = "", -- icon used for closed folds
  -- define log message filters
  filters = {
    -- The "level" key is used by the "toggle_filter" action, don't define it.
    level = nil,
    -- function that defines if a log entry should show or not.
    log = nil,
    -- function that defines if a trace entry should show or not.
    trace = nil,
  },
  signs = {
    mustfix = "󱎘",
    fatal = "󱎘",
    warning = "",
    info = "",
    slog = " ",
    count = " ",
    none = " ",
  },
  keys = { -- key mappings for actions in the trouble list
    q = 'close', -- close the list
    ['<esc>'] = 'cancel', -- cancel the preview and get back to your last window / buffer / cursor
    ['<cr>'] = 'jump', -- toggle fold or jump to the file
    ['<tab>'] = 'jump', -- toggle fold or jump to the file
    ['<c-x>'] = 'open_split', -- open buffer in new split
    ['<c-v>'] = 'open_vsplit', -- open buffer in new vsplit
    ['<c-t>'] = 'open_tab', -- open buffer in new tab
    o = 'jump_close', -- jump to the file and close the list
    p = 'preview', -- preview the file's location
    f = 'toggle_filter', -- filter messages by the level of the log under the cursor
    K = 'hover', -- shows complete text on a popup
    P = 'paste', -- creates a paste containing the current trace (uses `pastry`)
    c = 'clear', -- clears the list of logs
  },
}

M.options = {}

local function is_fb_hostname(hostname)
  return vim.endswith(hostname, '.fbinfra.net') or vim.endswith(hostname, '.facebook.com')
end

local function get_tier()
  local hostname = vim.uv.os_gethostname()
  if not is_fb_hostname(hostname) then
    return nil
  end
  return string.match(hostname, '^%w+[.]%w+')
end

function M.setup(options)
  M.options = vim.tbl_deep_extend("force", {}, defaults, options or {})
  M.options.tier = M.options.tier or get_tier()
end

return M
