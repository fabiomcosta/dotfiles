local utils = require('utils')

return {
  'saghen/blink.cmp',
  dependencies = {
    'rafamadriz/friendly-snippets',
    'folke/lazydev.nvim',
  },
  version = 'v0.11',
  opts = {
    fuzzy = {
      prebuilt_binaries = {
        proxy = {
          url = utils.is_meta_server() and 'http://fwdproxy:8080' or nil
        }
      }
    },
    keymap = { preset = 'super-tab' },
    appearance = {
      use_nvim_cmp_as_default = true,
    },
    sources = {
      -- add lazydev to your completion providers
      default = { 'lazydev', 'lsp', 'path', 'snippets', 'buffer' },
      providers = {
        lazydev = {
          name = 'LazyDev',
          module = 'lazydev.integrations.blink',
          -- make lazydev completions top priority (see `:h blink.cmp`)
          score_offset = 100,
        },
      },
      cmdline = {},
    },
    completion = {
      documentation = {
        auto_show = true,
        window = {
          border = 'rounded',
        },
      },
    },
  },
}
