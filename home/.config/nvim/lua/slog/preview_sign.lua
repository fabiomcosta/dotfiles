-- API to interact with the sign added on file preview.

local M = {}

function M.define()
  vim.fn.sign_define('SlogPreviewHighlightSign', { linehl = 'CursorLine', text = '=>' })
end

function M.unplace_all()
  vim.fn.sign_unplace('SlogPreviewHighlightSignGroup')
end

function M.place(opts)
  vim.fn.sign_place(0, 'SlogPreviewHighlightSignGroup', 'SlogPreviewHighlightSign', vim.fn.bufname(opts.buf),
    { lnum = opts.lnum })
end

return M
