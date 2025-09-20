local utils = require('utils')
local set_keymap = utils.set_keymap

return {
  'neovim/nvim-lspconfig',
  dependencies = {
    'saghen/blink.cmp',
    'meta.nvim',
  },
  config = function()
    set_keymap('n', '[d', '<cmd>lua vim.diagnostic.goto_prev()<CR>')
    set_keymap('n', ']d', '<cmd>lua vim.diagnostic.goto_next()<CR>')

    local on_attach = function(client, bufnr)
      utils.auto_format_on_save(client, bufnr)

      local function buf_set_keymap(mode, keys, action)
        vim.keymap.set(
          mode,
          keys,
          action,
          { noremap = true, silent = false, buffer = bufnr }
        )
      end

      -- Use lsp find_references if its available, and fallback to a grep_string.
      if client.server_capabilities.find_references then
        buf_set_keymap('n', '<LEADER>fr', '<CMD>Telescope lsp_references<CR>')
      elseif utils.is_biggrep_repo() then
        -- Use Telescope biggrep with the current selection
        buf_set_keymap('n', '<LEADER>fr', "viw:'<,'>Bgs<CR>")
      else
        buf_set_keymap('n', '<LEADER>fr', '<CMD>Telescope grep_string<CR>')
      end

      buf_set_keymap('n', 'gd', '<CMD>lua vim.lsp.buf.definition()<CR>')
      buf_set_keymap('n', '<LEADER>rn', '<CMD>lua vim.lsp.buf.rename()<CR>')
      buf_set_keymap('n', '<leader>ca', function()
        require('tiny-code-action').code_action()
      end)
    end

    local function with_lsp_default_config(config)
      config = config or {}
      return vim.tbl_deep_extend('keep', config, {
        on_attach = on_attach,
        capabilities = require('blink.cmp').get_lsp_capabilities(
          config.capabilities
        ),
        flags = {
          debounce_text_changes = 150,
        },
      })
    end

    local function lsp_enable(lsp_name, config)
      vim.lsp.config(lsp_name, with_lsp_default_config(config))
      vim.lsp.enable(lsp_name)
    end

    local nvim_lsp_util = require('lspconfig.util')

    local flow_root_dir_finder = nvim_lsp_util.root_pattern('.flowconfig')
    lsp_enable('flow', {
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
    })

    if utils.is_meta_server() then
      lsp_enable('hhvm')

      lsp_enable('relay_lsp', {
        cmd = { 'relay', 'lsp' },
        root_dir = function()
          return utils.get_arc_root()
        end,
      })

      local installed_extensions =
          require('meta.lsp.extensions').get_installed_extensions()

      if installed_extensions['nuclide.meta-prettier-vscode'] then
        lsp_enable('prettier@meta')
      end
      if installed_extensions['nuclide.eslint'] then
        lsp_enable('eslint@meta')
      end
      if installed_extensions['nuclide.erlang'] then
        lsp_enable('erlang@meta')
      end

      -- lsp_enable('eslint@meta', {
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
      -- })
    else
      lsp_enable('pylsp')
      lsp_enable('rust_analyzer')
      lsp_enable('ts_ls', {
        filetypes = { 'typescript', 'typescriptreact', 'typescript.tsx' },
      })
      lsp_enable('eslint', {
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
      })
      lsp_enable('lua_ls', {
        settings = {
          Lua = {
            telemetry = { enable = false },
            diagnostics = {
              -- Get the language server to recognize the `vim` global
              globals = { 'vim' },
            },
          },
        },
      })
    end
  end,
}
