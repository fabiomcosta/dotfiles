local lsp_util = require("lspconfig.util")
local meta_util = require("meta.util")
local meta_lsp = require("meta.lsp")

local binary_folder = meta_util.get_first_matching_dir(
  meta_lsp.VSCODE_EXTS_INSTALL_DIR .. "/nuclide.prettier*"
)

local binary = nil
local server_path = nil

if binary_folder then
  binary = 'node'
  server_path = binary_folder .. "/server/server.js"
end

return {
  default_config = meta_lsp.with_meta_default_config({
    cmd = { binary, server_path },
    filetypes = { "javascript", "javascript.jsx", "typescript" },
    root_dir = lsp_util.root_pattern(".arcconfig"),
  }),
  docs = {
    description = [[
prettier - JavaScript formatter language server
]],
  },
}

