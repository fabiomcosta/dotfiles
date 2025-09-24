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

    lsp_enable('flow', {
      cmd = { 'flow', 'lsp' },
    })

    if utils.is_meta_server() then
      lsp_enable('hhvm')

      lsp_enable('relay_lsp', {
        cmd = { 'relay', 'lsp' },
        root_dir = function(bufnr, on_dir)
          on_dir(utils.get_arc_root())
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
