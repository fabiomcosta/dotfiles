local utils = require('secrets.meta.utils')
local auto_format_on_save = require('utils').auto_format_on_save

return {
  'mason-org/mason-lspconfig.nvim',
  dependencies = {
    'saghen/blink.cmp',
    'meta.nvim',
    'neovim/nvim-lspconfig',
    { 'mason-org/mason.nvim', opts = {} },
  },
  config = function()
    vim.keymap.set('n', '[d', vim.diagnostic.goto_prev)
    vim.keymap.set('n', ']d', vim.diagnostic.goto_next)
    vim.keymap.set('n', 'gd', vim.lsp.buf.definition)
    vim.keymap.set('n', '<LEADER>rn', vim.lsp.buf.rename)
    vim.keymap.set(
      'n',
      '<LEADER>ca',
      require('tiny-code-action').code_action,
      { noremap = true, silent = true }
    )
    vim.keymap.set('n', 'K', function()
      vim.lsp.buf.hover({ border = 'rounded', max_height = 25, max_width = 120 })
    end, { desc = 'Hover documentation' })

    local on_attach = function(client, bufnr)
      auto_format_on_save(client, bufnr)

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

    if utils.is_meta_server() then
      lsp_enable('hhvm')
      lsp_enable('flow', {
        cmd = { 'flow', 'lsp' },
      })

      -- from https://github.com/neovim/nvim-lspconfig/blob/master/lua/lspconfig/configs/relay_lsp.lua
      lsp_enable('relay_lsp', {
        cmd = { 'relay', 'lsp' },
        filetypes = {
          'javascript',
          'javascriptreact',
          'javascript.jsx',
          'typescript',
          'typescriptreact',
          'typescript.tsx',
        },
        root_markers = {
          'relay.config.json',
          'relay.config.js',
          'package.json',
        },
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
    else
      require('mason-lspconfig').setup({
        ensure_installed = {
          -- LSPs
          'lua_ls',
          'pylsp',
          'rust_analyzer',
          'eslint',
          'ts_ls',
          'kotlin_language_server',
          'ktlint',
          -- Formatters
          'stylua',
          'prettier',
        },
        automatic_enable = {
          exclude = {
            'ts_ls',
            'eslint',
            'lua_ls',
          },
        },
      })

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
