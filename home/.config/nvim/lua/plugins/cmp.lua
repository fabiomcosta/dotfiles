local utils = require('utils')

local meta_sources = utils.is_meta_server()
    and {
      -- 'meta_title',
      'meta_tags',
      'meta_tasks',
      'meta_revsub',
    }
    or {}

local meta_providers = utils.is_meta_server()
    and {
      -- meta_title = {
      --   name = 'MetaTitle',
      --   module = 'meta.cmp.title',
      -- },
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
    or {}

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
          url = utils.is_meta_server() and 'http://fwdproxy:8080' or nil,
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
      }, meta_sources),
      providers = vim.tbl_extend('keep', {
        lazydev = {
          name = 'LazyDev',
          module = 'lazydev.integrations.blink',
          -- make lazydev completions top priority (see `:h blink.cmp`)
          score_offset = 100,
        },
      }, meta_providers),
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
