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


local signs = { Error = "●", Warning = "●", Hint = "●", Information = "●" }
for type, icon in pairs(signs) do
  local hl = "LspDiagnosticsSign" .. type
  vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = "" })
end


vim.o.completeopt = 'menu,menuone,noselect'

local cmp = require'cmp'

cmp.setup({
  mapping = {
    ['<C-b>'] = cmp.mapping(cmp.mapping.scroll_docs(-4), { 'i', 'c' }),
    ['<C-f>'] = cmp.mapping(cmp.mapping.scroll_docs(4), { 'i', 'c' }),
    ['<C-Space>'] = cmp.mapping(cmp.mapping.complete(), { 'i', 'c' }),
    ['<C-y>'] = cmp.config.disable, -- Specify `cmp.config.disable` if you want to remove the default `<C-y>` mapping.
    ['<C-e>'] = cmp.mapping({
      i = cmp.mapping.abort(),
      c = cmp.mapping.close(),
    }),
    -- Accept currently selected item. If none selected, `select` first item.
    -- Set `select` to `false` to only confirm explicitly selected items.
    ['<CR>'] = cmp.mapping.confirm({ select = true }),
  },
  sources = cmp.config.sources({
    { name = 'nvim_lsp' },
  }, {
    { name = 'buffer' },
  })
})

-- Use buffer source for `/` (if you enabled `native_menu`, this won't work anymore).
cmp.setup.cmdline('/', {
  sources = {
    { name = 'buffer' }
  }
})

-- Use cmdline & path source for ':' (if you enabled `native_menu`, this won't work anymore).
-- cmp.setup.cmdline(':', {
--   sources = cmp.config.sources({
--     { name = 'path' }
--   }, {
--     { name = 'cmdline' }
--   })
-- })


require('lspsaga').init_lsp_saga({
  code_action_prompt = {
    -- This was making the "lamp" icon show on the cursor's line all the time
    -- for some projects.
    enable = false,
  }
})


local nvim_lsp = require('lspconfig')

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

local capabilities = require('cmp_nvim_lsp')
  .update_capabilities(vim.lsp.protocol.make_client_capabilities())

-- Use a loop to conveniently call 'setup' on multiple servers and
-- map buffer local keybindings when the language server attaches
local servers = { 'flow' }
for _, lsp in ipairs(servers) do
  nvim_lsp[lsp].setup({
    capabilities = capabilities,
    on_attach = on_attach,
    flags = {
      debounce_text_changes = 150,
    }
  })
end

-- nvim_lsp.flow.setup {
--   cmd = { 'npx', '--no-install', '--package', 'flow-bin', 'flow', 'lsp', '>', '||', 'flow', 'lsp' },
--   on_attach = on_attach,
--   flags = {
--     debounce_text_changes = 150,
--   }
-- }

local lsp_installer = require('nvim-lsp-installer')
lsp_installer.on_server_ready(function(server)
  local opts = {
    capabilities = capabilities,
    on_attach = on_attach,
    flags = {
      debounce_text_changes = 150,
    }
  }
  if server.name == 'sumneko_lua' then
    opts.settings = {
      Lua = {
        diagnostics = {
          -- Get the language server to recognize the `vim` global
          globals = {'vim', 'hs'},
        },
        workspace = {
          -- Make the server aware of Neovim runtime files
          library = vim.api.nvim_get_runtime_file("", true),
        },
        -- Do not send telemetry data containing a randomized but unique identifier
        telemetry = {
          enable = false,
        },
      },
    }
  end
  server:setup(opts)
end)


require('lualine').setup({
  options = { theme = 'dracula' }
})


require('neogit').setup({
  disable_commit_confirmation = true,
  disable_insert_on_commit = false
})


require('bufjump').setup()

local opts = { silent=true, noremap=true }
vim.api.nvim_set_keymap('n', '<C-p>', ':lua require("bufjump").backward()<CR>', opts)
vim.api.nvim_set_keymap('n', '<C-n>', ':lua require("bufjump").forward()<CR>', opts)
