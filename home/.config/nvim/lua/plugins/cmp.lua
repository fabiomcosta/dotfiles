local utils = require('utils')

local meta_opts = utils.is_meta_server() and {
  sources = {
    default = {
      'meta_tags',
      'meta_tasks',
      'meta_revsub'
    }
  },
  providers = {
    meta_tags = {
      name = 'MetaTags',
      module = 'meta.cmp.tags',
    },
    meta_tasks = {
      name = 'MetaTasks',
      module = 'meta.cmp.tasks',
    },
    meta_revsub = {
      name = 'MetaRevSub',
      module = 'meta.cmp.revsub',
    },
  }
} or {}

return {
  'saghen/blink.cmp',
  dependencies = {
    'rafamadriz/friendly-snippets',
    'folke/lazydev.nvim',
  },
  version = 'v1.*',
  opts = vim.tbl_deep_extend('force', {
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
    cmdline = {
      sources = {}
    },
    sources = {
      default = {
        -- add lazydev to your completion providers
        'lazydev',
        'lsp',
        'path',
        'snippets',
        'buffer',
      },
      providers = {
        lazydev = {
          name = 'LazyDev',
          module = 'lazydev.integrations.blink',
          -- make lazydev completions top priority (see `:h blink.cmp`)
          score_offset = 100,
        },
      },
    },
    completion = {
      documentation = {
        auto_show = true,
        window = {
          border = 'rounded',
        },
      },
    },
  }, meta_opts),
}
