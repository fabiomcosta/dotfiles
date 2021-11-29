require('nvim-treesitter.configs').setup({
  ensure_installed = { 'javascript', 'typescript', 'tsx', 'lua', 'html', 'fish', 'json', 'yaml', 'scss', 'css', 'python', 'bash', 'erlang', 'graphql', 'vim' },
  highlight = {
    enable = true,
  },
  indent = {
    enable = false,
  },
  autotag = {
    enable = true,
  },
  context_commentstring = {
    enable = true
  }
})
local parser_config = require 'nvim-treesitter.parsers'.get_parser_configs()
parser_config.tsx.used_by = 'javascript'


require('lspsaga').init_lsp_saga({
  code_action_prompt = {
    -- This was making the "lamp" icon show on the cursor's line all the time
    -- for some projects.
    enable = false,
  }
})


local nvim_lsp = require('lspconfig')

local signs = { Error = "●", Warning = "●", Hint = "●", Information = "●" }
for type, icon in pairs(signs) do
  local hl = "LspDiagnosticsSign" .. type
  vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = "" })
end

-- Use an on_attach function to only map the following keys
-- after the language server attaches to the current buffer
local on_attach = function(client, bufnr)
  local function buf_set_keymap(...) vim.api.nvim_buf_set_keymap(bufnr, ...) end
  local function buf_set_option(...) vim.api.nvim_buf_set_option(bufnr, ...) end

  -- Mappings.
  local opts = { noremap=true, silent=true }

  -- See `:help vim.lsp.*` for documentation on any of the below functions

  buf_set_keymap('n', 'gd', '<cmd>lua vim.lsp.buf.definition()<CR>', opts)
  buf_set_keymap('n', '<LEADER>q', '<cmd>lua vim.lsp.diagnostic.set_loclist()<CR>', opts)

  -- lspsaga key bindings
  buf_set_keymap('n', 'K', '<cmd>lua require"lspsaga.hover".render_hover_doc()<CR>', opts)
  buf_set_keymap('n', 'gh', '<cmd>lua require"lspsaga.provider".preview_definition()<CR>', opts)
  buf_set_keymap('n', 'gk', '<cmd>lua require"lspsaga.provider".lsp_finder()<CR>', opts)
  buf_set_keymap('n', '[d', '<cmd>lua require"lspsaga.diagnostic".lsp_jump_diagnostic_prev()<CR>', opts)
  buf_set_keymap('n', ']d', '<cmd>lua require"lspsaga.diagnostic".lsp_jump_diagnostic_next()<CR>', opts)
  buf_set_keymap('n', '<LEADER>e', '<cmd>lua require"lspsaga.diagnostic".show_line_diagnostics()<CR>', opts)
  buf_set_keymap('n', '<LEADER>rn', '<cmd>lua require"lspsaga.rename".rename()<CR>', opts)
  buf_set_keymap('n', '<LEADER>ca', '<cmd>lua require"lspsaga.codeaction".code_action()<CR>', opts)
  buf_set_keymap('v', '<LEADER>ca', ':<C-U>lua require"lspsaga.codeaction".range_code_action()<CR>', opts)

  buf_set_keymap('n', '<LEADER>lg', '<cmd>lua require("lspsaga.floaterm").open_float_terminal("lazygit")<CR>', opts)

end

-- Use a loop to conveniently call 'setup' on multiple servers and
-- map buffer local keybindings when the language server attaches
local servers = { 'flow' }
for _, lsp in ipairs(servers) do
  nvim_lsp[lsp].setup {
    on_attach = on_attach,
    flags = {
      debounce_text_changes = 150,
    }
  }
end

-- nvim_lsp.flow.setup {
--   cmd = { 'npx', '--no-install', '--package', 'flow-bin', 'flow', 'lsp', '>', '||', 'flow', 'lsp' },
--   on_attach = on_attach,
--   flags = {
--     debounce_text_changes = 150,
--   }
-- }


vim.o.completeopt = 'menuone,noselect'

-- https://github.com/neovim/nvim-lspconfig/wiki/Autocompletion
require('compe').setup({
  enabled = true,
  autocomplete = true,
  documentation = true,
  preselect = 'enable',
  min_length = 1,
  throttle_time = 80,
  source_timeout = 200,
  incomplete_delay = 400,
  source = {
    path = true,
    nvim_lsp = true,
  },
})


require('lualine').setup({
  options = { theme = 'dracula' }
})


require('neogit').setup({
  disable_commit_confirmation = true,
  disable_insert_on_commit = false
})
