-- @lint-ignore-every LUA_LUAJIT
local lsp_util = require("lspconfig.util")
local meta_lsp = require("meta.lsp")

local binary_folder, _ = meta_lsp.extensions.get_latest_ext_path(
  "nuclide.prettier"
)

local cmd = {}

if binary_folder then
  cmd = { meta_lsp.NODE_BINARY, binary_folder .. "/server/server.js" }
end

return {
  default_config = meta_lsp.with_meta_default_config({
    cmd = cmd,
    -- Based on https://fburl.com/code/srpigu7b
    filetypes = {
      "flow",
      "javascript",
      "javascriptreact",
      "javascriptflow",
      "javascript.jsx",
      "typescript",
      "typescriptreact",
      "typescript.jsx",
      "graphql",
      "json",
      "css",
      "less",
      "scss",
    },
    root_dir = lsp_util.root_pattern(".arcconfig"),
  }),
  docs = {
    description = [[
prettier - JavaScript formatter language server
]],
  },
}

