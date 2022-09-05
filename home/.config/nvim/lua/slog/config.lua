local M = {}

M.namespace = vim.api.nvim_create_namespace("slog")

local defaults = {
  debug = false,
  position = "bottom", -- position of the list can be: bottom, top, left, right
  height = 20, -- height of the trouble list when position is top or bottom
  width = 50, -- width of the list when position is left or right
  fold_open = "", -- icon used for open folds
  fold_closed = "", -- icon used for closed folds
  filters = {}, -- define log message filters
  signs = {
    mustfix = "",
    fatal = "",
    warning = "",
    info = "",
    slog = " ",
    count = " ",
    none = " ",
  },
  action_keys = { -- key mappings for actions in the trouble list
    close = "q", -- close the list
    cancel = "<esc>", -- cancel the preview and get back to your last window / buffer / cursor
    jump = { "<cr>", "<tab>" }, -- toggle fold or jump to the file
    open_split = "<c-x>", -- open buffer in new split
    open_vsplit = "<c-v>", -- open buffer in new vsplit
    open_tab = "<c-t>", -- open buffer in new tab
    jump_close = "o", -- jump to the file and close the list
    preview = "p", -- preview the file's location
    toggle_filter = "f", -- filter messages by the level of the log under the cursor
    hover = "K", -- shows complete text on a popup
    paste = "P", -- creates a paste containing the current trace (uses `pastry`)
    clear = "c", -- clears the list of logs
  },
}

M.options = {}

local function is_fb_hostname(hostname)
  return vim.endswith(hostname, '.fbinfra.net') or vim.endswith(hostname, '.facebook.com')
end

local function get_tier()
  local hostname = vim.loop.os_gethostname()
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
