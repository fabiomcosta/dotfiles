local utils = require('utils')
local set_keymap = utils.set_keymap

return {
  'neovim/nvim-lspconfig',
  dependencies = {
    'folke/neodev.nvim',
    'nvimdev/lspsaga.nvim',
    'hrsh7th/cmp-nvim-lsp',
    'meta.nvim',
  },
  config = function()
    set_keymap('n', '[d', '<cmd>lua vim.diagnostic.goto_prev()<CR>')
    set_keymap('n', ']d', '<cmd>lua vim.diagnostic.goto_next()<CR>')

    local on_attach = function(client, bufnr)
      utils.auto_format_on_save(client, bufnr)

      local function buf_set_keymap(mode, keys, remapped_keys)
        vim.api.nvim_buf_set_keymap(
          bufnr,
          mode,
          keys,
          remapped_keys,
          { noremap = true, silent = true }
        )
      end

      -- Use lsp find_references if its available, and fallback to a grep_string.
      if client.server_capabilities.find_references then
        buf_set_keymap('n', '<LEADER>fr', '<cmd>Telescope lsp_references<CR>')
      elseif utils.is_biggrep_repo() then
        -- Use Telescope biggrep with the current selection
        buf_set_keymap('n', '<LEADER>fr', "viw:'<,'>Bgs<CR>")
      else
        buf_set_keymap('n', '<LEADER>fr', '<cmd>Telescope grep_string<CR>')
      end

      buf_set_keymap('n', 'gd', '<cmd>lua vim.lsp.buf.definition()<CR>')
      buf_set_keymap(
        'n',
        '<LEADER>q',
        '<cmd>lua vim.lsp.diagnostic.set_loclist()<CR>'
      )
      buf_set_keymap('n', '<LEADER>rn', '<cmd>lua vim.lsp.buf.rename()<CR>')

      -- lspsaga key bindings
      buf_set_keymap('n', 'gh', '<CMD>Lspsaga peek_definition<CR>')
      buf_set_keymap('n', 'gk', '<CMD>Lspsaga finder<CR>')
      buf_set_keymap('n', '<LEADER>e', '<CMD>Lspsaga show_line_diagnostics<CR>')
      buf_set_keymap('n', '<LEADER>ca', '<CMD>Lspsaga code_action<CR>')
    end

    local capabilities = require('cmp_nvim_lsp').default_capabilities(
      vim.lsp.protocol.make_client_capabilities()
    )

    local function with_lsp_default_config(config)
      return vim.tbl_deep_extend('keep', config or {}, {
        on_attach = on_attach,
        capabilities = capabilities,
        flags = {
          debounce_text_changes = 150,
        },
      })
    end

    local nvim_lsp = require('lspconfig')
    local nvim_lsp_util = require('lspconfig.util')

    -- Use a loop to conveniently call 'setup' on multiple servers and
    -- map buffer local keybindings when the language server attaches
    local servers = {}

    local flow_root_dir_finder = nvim_lsp_util.root_pattern('.flowconfig')
    nvim_lsp.flow.setup(with_lsp_default_config({
      cmd = { 'flow', 'lsp' },
      root_dir = flow_root_dir_finder,
      on_new_config = function(config, new_root_dir)
        -- We'll only create new LSP client for root_dirs that are
        -- not the same as the one from the cwd, because the `flow` name
        -- is already used for that, avoiding the creation of a duplica
        -- client.
        if flow_root_dir_finder(vim.loop.cwd()) ~= new_root_dir then
          config.name = 'flow-' .. new_root_dir
          -- This makes LspRestart work with the new client configs
          local lspconfigs = require('lspconfig.configs')
          rawset(lspconfigs, config.name, lspconfigs.flow)
        end
      end,
    }))

    if utils.is_meta_server() then
      table.insert(servers, 'hhvm')

      nvim_lsp.relay_lsp.setup(with_lsp_default_config({
        cmd = { 'relay', 'lsp' },
        root_dir = function() return utils.get_arc_root() end,
      }))

      local installed_extensions =
        require('meta.lsp.extensions').get_installed_extensions()

      if installed_extensions['nuclide.prettier'] then
        table.insert(servers, 'prettier@meta')
      end
      if installed_extensions['nuclide.erlang'] then
        table.insert(servers, 'erlang@meta')
      end
      if installed_extensions['nuclide.eslint'] then
        table.insert(servers, 'eslint@meta')
      end
      -- nvim_lsp['eslint@meta'].setup(with_lsp_default_config({
      --   settings = {
      --     editor = {
      --       codeActionsOnSave = {
      --         source = { fixAll = { eslint = true } }
      --       },
      --     },
      --     eslint = {
      --       autofixOnSave = {
      --         ruleAllowlist = {
      --           "fb-www/order-requires",
      --           "lint/sort-requires",
      --           "@fb-tools/sort-requires"
      --         }
      --       }
      --     }
      --     ['editor.codeActionsOnSave'] = {
      --       ['source.fixAll.eslint'] = true
      --     },
      --     ['eslint.autofixOnSave.ruleAllowlist'] = {
      --       "fb-www/order-requires",
      --       "lint/sort-requires",
      --       "@fb-tools/sort-requires"
      --     }
      --   }
      -- }))
    else
      table.insert(servers, 'pylsp')
      nvim_lsp.tsserver.setup(with_lsp_default_config({
        filetypes = { 'typescript', 'typescriptreact', 'typescript.tsx' },
      }))
      nvim_lsp.eslint.setup(with_lsp_default_config({
        on_attach = function(client, bufnr)
          -- neovim's LSP client does not currently support dynamic capabilities
          -- registration, so we need to set the server capabilities of the
          -- eslint server ourselves!
          client.server_capabilities.documentFormattingProvider = true
          on_attach(client, bufnr)
        end,
        settings = {
          format = { enable = true }, -- this will enable formatting
        },
      }))
      nvim_lsp.lua_ls.setup(with_lsp_default_config({
        settings = {
          Lua = {
            -- Do not send telemetry data containing a randomized but unique identifier
            telemetry = { enable = false },
          },
        },
      }))
    end

    for _, lsp in ipairs(servers) do
      nvim_lsp[lsp].setup(with_lsp_default_config())
    end
  end,
}
