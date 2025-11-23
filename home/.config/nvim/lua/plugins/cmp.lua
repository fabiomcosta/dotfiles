local cmp = require('secrets.meta.cmp')

return {
  'saghen/blink.cmp',
  dependencies = {
    'rafamadriz/friendly-snippets',
    'folke/lazydev.nvim',
    'meta.nvim',
  },
  version = 'v1.*',
  opts = {
    fuzzy = {
      prebuilt_binaries = {
        proxy = {
          url = cmp.proxy,
        },
      },
    },
    keymap = { preset = 'super-tab' },
    appearance = {
      use_nvim_cmp_as_default = true,
    },
    cmdline = {
      enabled = false,
    },
    sources = {
      default = vim.list_extend({
        -- add lazydev to your completion providers
        'lazydev',
        'lsp',
        'path',
        'snippets',
        'buffer',
      }, cmp.sources),
      providers = vim.tbl_extend('keep', {
        lazydev = {
          name = 'LazyDev',
          module = 'lazydev.integrations.blink',
          -- make lazydev completions top priority (see `:h blink.cmp`)
          score_offset = 100,
        },
      }, cmp.providers),
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
