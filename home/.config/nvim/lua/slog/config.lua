local M = {}

M.namespace = vim.api.nvim_create_namespace("slog")

local defaults = {
  debug = false,
  position = "bottom", -- position of the list can be: bottom, top, left, right
  height = 10, -- height of the trouble list when position is top or bottom
  width = 50, -- width of the list when position is left or right
  fold_open = "", -- icon used for open folds
  fold_closed = "", -- icon used for closed folds
  auto_preview = false, -- automatically preview the location of the diagnostic. <esc> to close preview and go back to last window
  signs = {
    mustfix = "",
    fatal = "",
    warning = "",
    info = "",
    slog = "﫠",
    count = "",
    other = "",
  },
  action_keys = { -- key mappings for actions in the trouble list
    close = "q", -- close the list
    cancel = "<esc>", -- cancel the preview and get back to your last window / buffer / cursor
    refresh = "r", -- manually refresh
    jump = { "<cr>", "<tab>" }, -- jump to the diagnostic or open / close folds
    open_split = { "<c-x>" }, -- open buffer in new split
    open_vsplit = { "<c-v>" }, -- open buffer in new vsplit
    open_tab = { "<c-t>" }, -- open buffer in new tab
    jump_close = { "o" }, -- jump to the diagnostic and close the list
    toggle_preview = "P", -- toggle auto_preview
    hover = "K", -- opens a small popup with the full multiline message
    preview = "p", -- preview the diagnostic location
    close_folds = { "zM", "zm" }, -- close all folds
    open_folds = { "zR", "zr" }, -- open all folds
    toggle_fold = { "zA", "za" }, -- toggle fold of current file
    previous = "k", -- previous item
    next = "j", -- next item
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

M.setup()

return M
