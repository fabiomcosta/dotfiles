local utils = require('utils')

return {
  {
    'mfussenegger/nvim-dap',
    dependencies = { 'meta.nvim' },
    config = function()
      if not utils.module_exists('meta') then
        return
      end

      local dap = require('dap')

      local meta_util = require('meta.util')
      local meta_lsp = require('meta.lsp')
      local binary_folder = meta_util.get_first_matching_dir(
        meta_lsp.VSCODE_EXTS_INSTALL_DIR .. '/nuclide.hhvm*'
      )
      -- hhvm has been buggy to install lately... to avoid errors on startup
      -- let's do this check while I figure out what is gong on there.
      if binary_folder ~= nil then
        dap.adapters.hhvm = {
          type = 'executable',
          command = meta_lsp.NODE_BINARY,
          args = { binary_folder .. '/src/hhvmWrapper.js' },
        }
        dap.configurations.hack = {
          {
            type = 'hhvm',
            name = 'Attach to hhvm process',
            request = 'attach',
            action = 'attach',
            debugPort = 8999,
            -- not sure how this is used yet... but I know
            -- it's supposed to be either a nuclide:// or file:// uri.
            -- The core attach debugger functionality works just
            -- fine with it being an empty string.
            targetUri = '',
          },
        }
        dap.configurations.php = dap.configurations.hack
      end
    end,
  },
  {
    'jbyuki/one-small-step-for-vimkind',
    dependencies = {
      'mfussenegger/nvim-dap',
    },
    config = function()
      local dap = require('dap')
      dap.configurations.lua = {
        {
          type = 'nlua',
          request = 'attach',
          name = 'Attach to running Neovim instance',
        },
      }
      dap.adapters.nlua = function(callback, config)
        callback({
          type = 'server',
          host = config.host or '127.0.0.1',
          port = config.port or 8086,
        })
      end
    end,
  },
  {
    'theHamsta/nvim-dap-virtual-text',
    dependencies = {
      'mfussenegger/nvim-dap',
      'nvim-treesitter/nvim-treesitter',
    },
    config = function()
      require('nvim-dap-virtual-text').setup({})
    end,
  },
  {
    'rcarriga/nvim-dap-ui',
    dependencies = {
      'mfussenegger/nvim-dap',
      'nvim-neotest/nvim-nio',
      'jbyuki/one-small-step-for-vimkind',
    },
    config = function()
      require('dapui').setup()

      local dap = require('dap')
      vim.keymap.set('n', '<LEADER>dmc', function()
        dap.toggle_breakpoint()
        vim.cmd('tabnew %')
        vim.cmd('AccordionStop')
        vim.cmd([[execute "normal! \<c-o>"]])
        require('dap').repl.open()
        require('dapui').open()
        if vim.o.ft == 'lua' then
          require('osv').run_this()
        else
          dap.continue()
        end
      end)
      vim.keymap.set('n', '<LEADER>dmx', function()
        dap.terminate()
        dap.clear_breakpoints()
        require('dapui').close()
        vim.cmd('tabclose')
        vim.cmd('AccordionAutoResize')
      end)
      vim.keymap.set('n', '<LEADER>dc', dap.continue)
      vim.keymap.set('n', '<LEADER>dn', dap.step_over)
      vim.keymap.set('n', '<LEADER>di', dap.step_into)
      vim.keymap.set('n', '<LEADER>do', dap.step_out)
      vim.keymap.set('n', '<LEADER>dbt', dap.toggle_breakpoint)
      vim.keymap.set('n', '<LEADER>dbc', dap.clear_breakpoints)
      vim.keymap.set('n', '<LEADER>dbl', dap.list_breakpoints)
      vim.keymap.set('n', '<LEADER>dh', function()
        require('dapui').eval()
      end)
      vim.keymap.set('n', '<LEADER>du', function()
        require('dapui').toggle()
      end)
    end,
  },
}
