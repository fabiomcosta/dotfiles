return {
  {
    'theHamsta/nvim-dap-virtual-text',
    dependencies = {
      'mfussenegger/nvim-dap',
    },
    config = true,
  },
  {
    'LiadOz/nvim-dap-repl-highlights',
    dependencies = {
      'mfussenegger/nvim-dap',
    },
    config = true,
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
    'rcarriga/nvim-dap-ui',
    dependencies = {
      'mfussenegger/nvim-dap',
      'nvim-neotest/nvim-nio',
      'jbyuki/one-small-step-for-vimkind',
    },
    config = function()
      local dap, dapui = require('dap'), require('dapui')
      dapui.setup()

      vim.keymap.set('n', '<LEADER>dmc', function()
        dap.toggle_breakpoint()
        vim.cmd('tabnew %')
        vim.cmd('AccordionStop')
        -- Moves cursor at the "current" place in the new tab.
        -- Without this the cursor moves to the top of the file.
        vim.cmd([[execute "normal! \<c-o>"]])
        dapui.open()
        if vim.o.ft == 'lua' then
          require('osv').run_this()
        else
          dap.continue()
        end
      end)
      vim.keymap.set('n', '<LEADER>dmx', function()
        dap.terminate()
        dap.clear_breakpoints()
        dapui.close()
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
        dapui.eval()
      end)
      vim.keymap.set('n', '<LEADER>du', function()
        dapui.toggle()
      end)
    end,
  },
}
