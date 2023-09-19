local IS_META_SERVER = (function()
  local hostname = vim.loop.os_gethostname()
  return vim.endswith(hostname, '.fbinfra.net')
      or vim.endswith(hostname, '.facebook.com')
end)()

-- would be nice to make this async, lazy and memoized
local IS_ARC_ROOT = IS_META_SERVER
    and vim.fn.system({ 'arc', 'get-config', 'project_id' }) ~= ''

local set_keymap = vim.api.nvim_set_keymap

local utils = require('utils')

-- fonts and other gui stuff
-- make sure to install the powerline patched font
-- version of the font you like
-- https://github.com/Lokaltog/powerline-fonts
if vim.fn.has('gui_running') > 0 then
  vim.opt.guioptions:remove('T') -- remove toolbar
  vim.opt.guioptions:remove('r') -- remove right-hand scroll bar
  vim.opt.guioptions:remove('L') -- remove left-hand scroll bar

  -- activates ligatures when supported
  vim.opt.macligatures = true
  vim.opt.guifont = 'JetBrainsMono Nerd Font:h16'
end

vim.g.mapleader = ','

-- avoiding possible issues on plugins that are generaly only tested on bash.
vim.opt.shell = 'bash'
-- vim can merge signcolumn and number column into one
vim.opt.signcolumn = 'number'

-- adds possibility of using 256 colors
vim.opt.termguicolors = true
-- vim.opt.t_8b = '^[[48;2;%lu;%lu;%lum'
-- vim.opt.t_8f = '^[[38;2;%lu;%lu;%lum'
-- vim.opt.t_Co = '256'
-- vim.opt.t_ut = nil

-- only show file name on tabs
vim.opt.tabline = '%t'

-- for the dark version
vim.opt.background = 'dark'

-- default indent settings
vim.opt.expandtab = true
vim.opt.tabstop = 2
vim.opt.softtabstop = 2
vim.opt.shiftwidth = 2
vim.opt.shiftround = true

vim.opt.autoread = true
vim.opt.backup = false
vim.opt.writebackup = false
vim.opt.swapfile = false
vim.opt.visualbell = true
vim.opt.errorbells = false
vim.opt.encoding = 'utf-8'
-- a large value will help prevent the weid scroll jump while changing focus
-- between buffers. It also helps keep the cursor more to the center of
-- the screen.
vim.opt.scrolloff = 999
vim.opt.autoindent = true
vim.opt.copyindent = true
vim.opt.title = true
vim.opt.showmode = true
vim.opt.showcmd = true
vim.opt.hidden = true
vim.opt.ruler = true
vim.opt.lazyredraw = true
-- allows colors on long lines
vim.opt.synmaxcol = 5000
-- allow backspacing over everything in insert mode
vim.opt.backspace = { 'indent', 'eol', 'start' }
-- font line-height
vim.opt.linespace = 0
-- adds line numbers to the left
vim.opt.number = true
-- prevents delay while pressing esc on insert mode
vim.opt.timeoutlen = 5000
vim.opt.ttimeoutlen = 0
-- uses OS clipboard if possible (check +clipboard)
vim.opt.clipboard:append({ 'unnamed', 'unnamedplus' })
-- store lots of :cmdline history
vim.opt.history = 1000
-- mark the ideal max text width
vim.opt.colorcolumn = '80'
-- some stuff to get the mouse going in term
vim.opt.mouse = 'a'
-- keep going up dirs until a tags file is found
vim.opt.tags = 'tags;/'

-- enable ctrl-n and ctrl-p to scroll through matches
vim.opt.wildmenu = true
-- make cmdline tab completion similar to bash
vim.opt.wildmode = { 'longest', 'full' }
-- ignored files while searching files and stuff
vim.opt.wildignore = {
  '*~',
  '*.i',
  '*.d',
  '*.so',
  '*.gz',
  '*.zip',
  '*.tar',
  '*.exe',
  '*.dll',
  '*.swf',
  '*.swp',
  '*.swo',
  '*.pyc',
  '*.psd',
  '*.pdf',
  '*.png',
  '*.gif',
  '*.jpg',
  '*.jpeg',
  '*.sql3',
  '*/tmp/*',
  '*/.hq/*',
  '*/.git/*',
  '*/.svn/*',
  '*/.sass-cache/*',
  '*/.yarn-cache/*',
  '*/submodules/*',
  '*/custom_modules/*',
  'tags',
}

-- ignores case
vim.opt.ignorecase = true
-- do not ignore case if explicitly defined on the search
-- by search for an uppercased pattern
vim.opt.smartcase = true
-- defaults to search for every match of the pattern
vim.opt.gdefault = true
vim.opt.showmatch = true
-- dont wrap lines
vim.opt.wrap = true
-- wrap lines at convenient points
vim.opt.linebreak = true
vim.opt.textwidth = 360
vim.opt.formatoptions = 'qrn1'
-- -- display tabs and trailing spaces
vim.opt.list = true
vim.opt.listchars = { tab = '▸\\ ', eol = '¬' }
-- folding options
vim.opt.foldmethod = 'indent'
vim.opt.foldenable = false

vim.opt.jumpoptions:append({ 'stack' })

vim.opt.completeopt = { 'menu', 'menuone', 'noselect' }

-- so vim won't force pep8 on all python files
vim.g.python_recommended_style = 0

set_keymap('n', 'j', 'gj', { noremap = true })
set_keymap('n', 'k', 'gk', { noremap = true })

-- moves cursor faster
set_keymap('n', '<DOWN>', '12j', { noremap = true })
set_keymap('v', '<DOWN>', '12j', { noremap = true })
set_keymap('n', '<UP>', '12k', { noremap = true })
set_keymap('v', '<UP>', '12k', { noremap = true })

set_keymap('i', 'jj', '<ESC>', { noremap = true })
set_keymap('n', ';', ':', { noremap = true })
set_keymap('v', ';', ':', { noremap = true })

-- makes ctrl-v work on command-line and search modes
set_keymap('c', '<C-v>', '<C-r>"', { noremap = true })
set_keymap('s', '<C-v>', '<C-r>"', { noremap = true })

local initLuaFilePath = debug.getinfo(1).source:sub(2)
set_keymap(
  'n',
  '<LEADER>ev',
  ':e ' .. initLuaFilePath .. '<CR>',
  { noremap = true }
)
set_keymap('n', '<LEADER>\\', ':vsplit<CR><C-w>l', { noremap = true })
set_keymap('n', '<LEADER>-', ':split<CR><C-w>j', { noremap = true })

-- changes the size of the buffer windows
set_keymap('n', '=', '<C-w>=', { noremap = true })
set_keymap('n', '<RIGHT>', ':vertical resize +5<CR>', { noremap = true })
set_keymap('n', '<LEFT>', ':vertical resize -5<CR>', { noremap = true })
set_keymap('n', '+', ':resize +5<CR>', { noremap = true })
set_keymap('n', '-', ':resize -5<CR>', { noremap = true })

-- tab related mappings
set_keymap('n', '<LEADER>tc', ':tabnew<CR>', { noremap = true })
set_keymap('n', '<LEADER>tp', ':tabprevious<CR>', { noremap = true })
set_keymap('n', '<LEADER>tn', ':tabnext<CR>', { noremap = true })

-- avoid going on ex mode
set_keymap('n', 'Q', '<NOP>', { noremap = true })

-- copies current buffer file path relative to cwd to register
vim.keymap.set('n', 'cp', function()
  local path = vim.fn.resolve(vim.fn.fnamemodify(vim.fn.expand('%'), ':~:.'))
  vim.fn.setreg('+', path)
  utils.require_if_exists('osc52', function(osc52)
    osc52.copy(path)
  end)
end)

-- copies current buffer filename to register
vim.keymap.set('n', 'cf', function()
  local filename = vim.fn.resolve(vim.fn.fnamemodify(vim.fn.expand('%'), ':t'))
  vim.fn.setreg('+', filename)
  utils.require_if_exists('osc52', function(osc52)
    osc52.copy(filename)
  end)
end)

-- Keeps selection when changing indentation
-- https://github.com/mhinz/vim-galore#dont-lose-selection-when-shifting-sidewards
set_keymap('x', '<', '<gv', { noremap = true })
set_keymap('x', '>', '>gv', { noremap = true })

-- Disable cursorline highlight on insert mode
-- https://github.com/mhinz/vim-galore#smarter-cursorline
vim.cmd([[autocmd InsertLeave,WinEnter * set cursorline]])
vim.cmd([[autocmd InsertEnter,WinLeave * set nocursorline]])

vim.filetype.add({
  extension = {
    php = function(path, bufnr)
      if vim.startswith(vim.filetype.getlines(bufnr, 1), '<?hh') then
        return 'hack',
            function(bufnr)
              vim.opt_local.syntax = 'php'
              vim.opt_local.iskeyword:append('$')
            end
      end
      return 'php'
    end,
  },
})

local lazypath = vim.fn.stdpath('data') .. '/lazy/lazy.nvim'
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    'git',
    'clone',
    '--filter=blob:none',
    'https://github.com/folke/lazy.nvim.git',
    '--branch=stable', -- latest stable release
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

local augroup = vim.api.nvim_create_augroup('LspFormatting', {})
local auto_format_on_save = function(client, bufnr)
  -- if client.server_capabilities.document_formatting then
  if client.supports_method('textDocument/formatting') then
    -- vim.cmd([[
    --   augroup Format
    --     autocmd! * <buffer>
    --     autocmd BufWritePre <buffer> lua vim.lsp.buf.format({ timeout_ms = 2000 })
    --   augroup END
    -- ]])
    vim.api.nvim_clear_autocmds({ group = augroup, buffer = bufnr })
    vim.api.nvim_create_autocmd('BufWritePre', {
      group = augroup,
      buffer = bufnr,
      callback = function()
        vim.lsp.buf.format({ timeout_ms = 2000 })
      end,
    })
  end
end

require('lazy').setup({
  {
    'dracula/vim',
    name = 'dracula',
    lazy = false,
    priority = 1000, -- loads this before all the other start plugins
    config = function()
      vim.cmd([[colorscheme dracula]])
    end,
  },
  {
    'othree/eregex.vim',
    config = function()
      vim.g.eregex_default_enable = 0
    end,
  },
  { 'antoinemadec/FixCursorHold.nvim' },
  { 'jordwalke/VimAutoMakeDirectory' },
  { 'tpope/vim-git' },
  { 'tpope/vim-surround' },
  { 'tpope/vim-repeat' },
  { 'tpope/vim-fugitive' },
  { 'tpope/vim-commentary' },
  {
    'tpope/vim-projectionist',
    config = function()
      set_keymap('n', '<LEADER>a', ':A<CR>', { silent = true, noremap = true })
      local jest_alternate = {
        ['**/__tests__/*.test.js'] = {
          alternate = '{}.js',
          type = 'test',
        },
        ['*.js'] = {
          alternate = '{dirname}/__tests__/{basename}.test.js',
          type = 'source',
        },
      }
      vim.g.projectionist_heuristics = {
        ['jest.config.js|jest.config.ts'] = jest_alternate,
        ['.arcconfig'] = vim.tbl_deep_extend('keep', {
          ['**/__tests__/*Test.php'] = {
            alternate = '{}.php',
            type = 'test',
          },
          ['*.php'] = {
            alternate = '{dirname}/__tests__/{basename}Test.php',
            type = 'source',
          },
        }, jest_alternate),
      }
    end,
  },
  { 'moll/vim-node' },
  -- { 'jparise/vim-graphql' },
  { 'christoomey/vim-tmux-navigator' },

  -- TODO remove this plugin once 0.9 is available as it has editorconfig
  -- support builtin :)
  { 'editorconfig/editorconfig-vim' },

  {
    'ojroques/nvim-osc52',
    config = function()
      require('osc52').setup({ silent = true })

      local function copy()
        if vim.v.event.operator == 'y' and vim.v.event.regname == '' then
          require('osc52').copy_register('"')
        end
      end
      vim.api.nvim_create_autocmd('TextYankPost', { callback = copy })
    end,
  },
  -- { 'godlygeek/tabular' },
  -- { 'jeffkreeftmeijer/vim-numbertoggle' },

  {
    'kwkarlwang/bufjump.nvim',
    config = function()
      require('bufjump').setup({
        backward = '<C-b>',
        forward = '<C-n>',
      })
      set_keymap('n', '<C-p>', '<C-w>p', { silent = true, noremap = true })
    end,
  },

  -- not needed on vscode
  { 'ntpeters/vim-better-whitespace' },
  {
    -- This plugin already constains 'tpope/vim-sleuth'
    'sheerun/vim-polyglot',
    config = function()
      vim.g.javascript_plugin_flow = 1
    end,
  },
  {
    'haya14busa/incsearch.vim',
    config = function()
      vim.opt.hlsearch = true
      vim.g['incsearch#auto_nohlsearch'] = 1
      set_keymap('', '/', '<Plug>(incsearch-forward)', { noremap = false })
      set_keymap('', 'n', '<Plug>(incsearch-nohl-n)', { noremap = false })
      set_keymap('', 'N', '<Plug>(incsearch-nohl-N)', { noremap = false })
      set_keymap('', '*', '<Plug>(incsearch-nohl-*)', { noremap = false })
      set_keymap('', '#', '<Plug>(incsearch-nohl-#)', { noremap = false })
      set_keymap('', 'g*', '<Plug>(incsearch-nohl-g*)', { noremap = false })
      set_keymap('', 'g#', '<Plug>(incsearch-nohl-g#)', { noremap = false })
      set_keymap(
        '',
        '<LEADER>/',
        '<Plug>(incsearch-forward)<C-r><C-w><CR>',
        { noremap = false }
      )
    end,
  },
  {
    'rhysd/git-messenger.vim',
    config = function()
      vim.g.git_messenger_floating_win_opts = { border = 'single' }
      vim.g.git_messenger_popup_content_margins = false
      set_keymap(
        'n',
        '<LEADER>gm',
        ':GitMessenger<CR>',
        { silent = true, noremap = false }
      )
    end,
  },
  {
    'tpope/vim-vinegar',
    config = function()
      vim.g.netrw_liststyle = 3
      set_keymap(
        'n',
        '<LEADER>z',
        ':Vexplore<CR>',
        { silent = true, noremap = true }
      )
    end,
  },

  {
    'tversteeg/registers.nvim',
    name = 'registers',
    -- keys = {
    --   { "\"",    mode = { "n", "v" } },
    --   { "<C-R>", mode = "i" }
    -- },
    cmd = 'Registers',
  },

  {
    'nvim-treesitter/nvim-treesitter',
    build = function()
      require('nvim-treesitter.install').prefer_git = true
      require('nvim-treesitter.install').update({ with_sync = true })()
    end,
    config = function()
      require('nvim-treesitter.install').prefer_git = true
      require('nvim-treesitter.configs').setup({
        ensure_installed = {
          'javascript',
          'typescript',
          'tsx',
          'lua',
          'html',
          'fish',
          'json',
          'yaml',
          'scss',
          'css',
          'python',
          'bash',
          'erlang',
          'graphql',
          'hack',
        },
        highlight = {
          enable = true,
          disable = { 'lua' },
        },
        indent = {
          enable = true,
        },
        autotag = {
          enable = true,
        },
        context_commentstring = {
          enable = true,
        },
        -- refactor = {
        --   highlight_definitions = { enable = true },
        --   smart_rename = {
        --     enable = true,
        --     keymaps = {
        --       smart_rename = '<LEADER>rn',
        --     },
        --   },
        -- },
      })
    end,
  },

  {
    'nvim-treesitter/nvim-treesitter-refactor',
    dependencies = { 'nvim-treesitter/nvim-treesitter' },
  },
  {
    'windwp/nvim-ts-autotag',
    dependencies = { 'nvim-treesitter/nvim-treesitter' },
  },
  {
    'JoosepAlviste/nvim-ts-context-commentstring',
    dependencies = { 'nvim-treesitter/nvim-treesitter' },
  },

  {
    'hrsh7th/nvim-cmp',
    dependencies = {
      'onsails/lspkind-nvim',
      'hrsh7th/cmp-nvim-lsp',
      'hrsh7th/cmp-buffer',
      'hrsh7th/cmp-path',
      'hrsh7th/cmp-cmdline',
      'hrsh7th/cmp-vsnip',
      'hrsh7th/vim-vsnip',
      'rafamadriz/friendly-snippets',
    },
    config = function()
      local cmp = require('cmp')
      cmp.setup({
        snippet = {
          expand = function(args)
            vim.fn['vsnip#anonymous'](args.body)
          end,
        },
        formatting = {
          format = require('lspkind').cmp_format(),
        },
        mapping = cmp.mapping.preset.insert({
          ['<C-b>'] = cmp.mapping.scroll_docs(-4),
          ['<C-f>'] = cmp.mapping.scroll_docs(4),
          ['<C-e>'] = cmp.mapping.abort(),
          -- Accept currently selected item. If none selected, `select` first item.
          -- Set `select` to `false` to only confirm explicitly selected items.
          ['<CR>'] = cmp.mapping.confirm({ select = true }),
        }),
        window = {
          documentation = cmp.config.window.bordered(),
        },
        sources = cmp.config.sources({
          { name = 'nvim_lsp' },
          { name = 'vsnip' },
        }, {
          { name = 'buffer' },
        }),
      })
    end,
  },
  {
    'folke/neodev.nvim',
    config = function()
      require('neodev').setup()
    end,
  },
  {
    'neovim/nvim-lspconfig',
    dependencies = {
      'folke/neodev.nvim',
      'kkharji/lspsaga.nvim',
      'hrsh7th/cmp-nvim-lsp',
      'meta.nvim',
    },
    config = function()
      set_keymap(
        'n',
        '[d',
        '<cmd>lua vim.diagnostic.goto_prev()<CR>',
        { silent = true, noremap = true }
      )
      set_keymap(
        'n',
        ']d',
        '<cmd>lua vim.diagnostic.goto_next()<CR>',
        { silent = true, noremap = true }
      )

      local on_attach = function(client, bufnr)
        auto_format_on_save(client, bufnr)

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
          -- The ideal check here is to check for biggrep support somehow
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
        buf_set_keymap(
          'n',
          'K',
          '<cmd>lua require"lspsaga.hover".render_hover_doc()<CR>'
        )
        buf_set_keymap(
          'n',
          'gh',
          '<cmd>lua require"lspsaga.provider".preview_definition()<CR>'
        )
        buf_set_keymap(
          'n',
          'gk',
          '<cmd>lua require"lspsaga.provider".lsp_finder()<CR>'
        )
        buf_set_keymap(
          'n',
          '[d',
          '<cmd>lua require"lspsaga.diagnostic".lsp_jump_diagnostic_prev()<CR>'
        )
        buf_set_keymap(
          'n',
          ']d',
          '<cmd>lua require"lspsaga.diagnostic".lsp_jump_diagnostic_next()<CR>'
        )
        buf_set_keymap(
          'n',
          '<LEADER>e',
          '<cmd>lua require"lspsaga.diagnostic".show_line_diagnostics()<CR>'
        )
        buf_set_keymap(
          'n',
          '<LEADER>ca',
          '<cmd>lua require"lspsaga.codeaction".code_action()<CR>'
        )
        buf_set_keymap(
          'v',
          '<LEADER>ca',
          ':<C-U>lua require"lspsaga.codeaction".range_code_action()<CR>'
        )
        buf_set_keymap(
          'n',
          '<LEADER>lg',
          '<cmd>lua require"lspsaga.floaterm".open_float_terminal("lazygit")<CR>'
        )
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

      if IS_META_SERVER then
        table.insert(servers, 'hhvm')

        local installed_extensions =
            require('meta.lsp.extensions').get_installed_extensions()
        if installed_extensions['nuclide.prettier'] then
          table.insert(servers, 'prettier@meta')
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
            -- neovim's LSP client does not currently support dynamic capabilities registration, so we need to set
            -- the server capabilities of the eslint server ourselves!
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
  },
  {
    'simrat39/rust-tools.nvim',
    dependencies = { 'neovim/nvim-lspconfig' },
    config = function()
      local rt = require('rust-tools')
      rt.setup({
        server = {
          on_attach = function(_, bufnr)
            -- Hover actions
            vim.keymap.set(
              'n',
              '<C-space>',
              rt.hover_actions.hover_actions,
              { buffer = bufnr }
            )
            -- Code action groups
            vim.keymap.set(
              'n',
              '<Leader>a',
              rt.code_action_group.code_action_group,
              { buffer = bufnr }
            )
            vim.keymap.set(
              'n',
              'gd',
              vim.lsp.buf.definition,
              { buffer = bufnr }
            )
          end,
        },
      })
    end,
  },
  {
    'williamboman/mason.nvim',
    config = function()
      require('mason').setup()
    end,
  },
  {
    'jose-elias-alvarez/null-ls.nvim',
    dependencies = { 'nvim-lua/plenary.nvim' },
    config = function()
      if not IS_META_SERVER then
        require('null-ls').setup({
          on_attach = function(client, bufnr)
            auto_format_on_save(client, bufnr)
          end,
          sources = {
            require('null-ls').builtins.formatting.black,
            require('null-ls').builtins.formatting.stylua,
            require('null-ls').builtins.formatting.prettier,
          },
        })
      end
    end,
  },

  {
    'kkharji/lspsaga.nvim',
    config = function()
      require('lspsaga').init_lsp_saga({
        code_action_prompt = {
          -- This was making the "lamp" icon show on the cursor's line all the time
          -- for some projects.
          enable = false,
        },
      })
    end,
  },

  { 'nvim-lua/popup.nvim' },
  {
    'nvim-telescope/telescope.nvim',
    dependencies = {
      'nvim-lua/plenary.nvim',
      'nvim-telescope/telescope-fzy-native.nvim',
    },
    config = function()
      local telescope_setup = {}
      if vim.fn.executable('fd') == 1 then
        telescope_setup.pickers = {
          find_files = {
            find_command = {
              'fd',
              '--type',
              'f',
              '--strip-cwd-prefix',
              '--exclude',
              'custom_modules',
              '--exclude',
              'submodules',
              '--exclude',
              'node_modules',
            },
          },
        }
      end
      if vim.fn.executable('rg') == 1 then
        telescope_setup.defaults = {
          vimgrep_arguments = {
            'rg',
            '--color=never',
            '--no-heading',
            '--with-filename',
            '--line-number',
            '--column',
            '--smart-case',
            '--trim',
          },
        }
      end
      require('telescope').setup(telescope_setup)
      require('telescope').load_extension('fzy_native')

      if IS_ARC_ROOT then
        -- myles only works on hg repos
        if utils.is_hg_repo() then
          set_keymap(
            'n',
            '<LEADER>ff',
            '<cmd>Telescope myles<CR>',
            { silent = false, noremap = true }
          )
        elseif utils.is_biggrep_repo() then
          set_keymap(
            'n',
            '<LEADER>ff',
            '<cmd>Telescope biggrep f<CR>',
            { silent = false, noremap = true }
          )
        else
          set_keymap(
            'n',
            '<LEADER>ff',
            '<cmd>Telescope find_files<CR>',
            { silent = false, noremap = true }
          )
          set_keymap(
            'n',
            '<LEADER>fg',
            '<cmd>Telescope live_grep<CR>',
            { silent = false, noremap = true }
          )
        end
        if utils.is_biggrep_repo() then
          set_keymap(
            'n',
            '<LEADER>fg',
            '<cmd>Telescope biggrep s<CR>',
            { silent = false, noremap = true }
          )
        end
      else
        set_keymap(
          'n',
          '<LEADER>ff',
          '<cmd>Telescope find_files<CR>',
          { silent = false, noremap = true }
        )
        set_keymap(
          'n',
          '<LEADER>fg',
          '<cmd>Telescope live_grep<CR>',
          { silent = false, noremap = true }
        )
      end

      set_keymap(
        'n',
        '<LEADER>fh',
        '<cmd>Telescope find_files hidden=true<CR>',
        { silent = false, noremap = true }
      )
      set_keymap(
        'n',
        '<LEADER>fb',
        '<cmd>Telescope buffers<CR>',
        { silent = false, noremap = true }
      )
      set_keymap(
        'n',
        '<LEADER>fd',
        '<cmd>Telescope diagnostics<CR>',
        { silent = false, noremap = true }
      )
      set_keymap(
        'n',
        '<LEADER>gs',
        '<cmd>Telescope git_status<CR>',
        { silent = false, noremap = true }
      )
    end,
  },

  {
    'TimUntersberger/neogit',
    config = function()
      require('neogit').setup({
        disable_commit_confirmation = true,
        disable_insert_on_commit = false,
      })
    end,
  },
  {
    'hoob3rt/lualine.nvim',
    dependencies = {
      'kyazdani42/nvim-web-devicons',
      'chipsenkbeil/distant.nvim',
    },
    config = function()
      -- local distant_status = require('meta-local').status
      require('lualine').setup({
        options = {
          theme = 'dracula',
        },
        sections = {
          lualine_a = { 'branch' },
          lualine_b = {},
          lualine_c = { { 'filename', path = 1 } },
          lualine_x = { 'diagnostics' },
          lualine_y = { 'filetype' },
          -- lualine_z = {
          --   {
          --     distant_status,
          --     map = function(text)
          --       local address = text[1]
          --       if address then
          --         address = address:gsub('.facebook.com$', '')
          --         address = address:gsub('.fbinfra.net$', '')
          --         text[1] = address
          --       end
          --       return text
          --     end,
          --   },
          -- },
        },
        inactive_sections = {
          lualine_c = { { 'filename', path = 1 } },
          lualine_x = {},
        },
      })
    end,
  },
  {
    'thaerkh/vim-workspace',
    config = function()
      vim.g.workspace_autosave = 0
      vim.g.workspace_autocreate = 1
      vim.g.workspace_session_disable_on_args = 1
      -- This plugin functionality makes no sense, it's completely unrelated from its
      -- core functionality :|
      vim.g.workspace_autosave_untrailspaces = 0
      vim.g.workspace_autosave_untrailtabs = 0

      vim.g.workspace_session_directory =
          vim.fn.expand(vim.fn.stdpath('data') .. '/sessions')
      vim.g.workspace_undodir =
          vim.fn.expand(vim.fn.stdpath('data') .. '/sessions/.undodir')
    end,
  },
  {
    'vim-test/vim-test',
    config = function()
      vim.g['test#strategy'] = 'neovim'
      vim.g['test#neovim#term_position'] = 'botright 20'
      vim.g['test#neovim#start_normal'] = 1
      vim.g['test#javascript#jest#options'] = '--verbose=false'
      vim.g['test#custom_runners'] = { PHP = { 'Arc' }, JavaScript = { 'Arc' } }

      -- Closes the last term window according to vim's order, so either the
      -- bottom-most or if there is none on the bottom, the last to the right.
      vim.keymap.set('n', '<LEADER>tk', function()
        local max_width = vim.o.columns
        local max_height = vim.o.lines - 1 - vim.o.cmdheight

        -- get winnr from last windows
        local last_window_nr = vim.fn.winnr('$')
        local window_width = vim.fn.winwidth(last_window_nr)
        local window_height = vim.fn.winheight(last_window_nr)

        local is_full_width = window_width == max_width
        local is_partial_height = window_height < max_height

        if is_full_width and is_partial_height then
          local last_window_id = vim.fn.win_getid(last_window_nr)
          local win_info = vim.fn.getwininfo(last_window_id)[1]
          if win_info.terminal == 1 then
            -- Sticky size/position
            vim.g['test#neovim#term_position'] = 'botright ' .. window_height
          end
          return utils.replace_termcodes('<C-w>' .. last_window_nr .. 'c')
        end
        return ''
      end, { silent = true, expr = true })

      set_keymap(
        'n',
        '<LEADER>tn',
        '<LEADER>tk:TestNearest<CR><C-w>p',
        { silent = true, noremap = false }
      )
      set_keymap(
        'n',
        '<LEADER>tf',
        '<LEADER>tk:TestFile<CR><C-w>p',
        { silent = true, noremap = false }
      )
      set_keymap(
        'n',
        '<LEADER>ts',
        '<LEADER>tk:TestSuite<CR><C-w>p',
        { silent = true, noremap = false }
      )
      set_keymap(
        'n',
        '<LEADER>tl',
        '<LEADER>tk:TestLast<CR><C-w>p',
        { silent = true, noremap = false }
      )
      set_keymap(
        'n',
        '<LEADER>tg',
        ':TestVisit<CR>',
        { silent = true, noremap = false }
      )
    end,
  },
  {
    'mattboehm/vim-accordion',
    config = function()
      -- This makes sure that accordion won't change the height of horizontal
      -- windows/buffers when it calls "wincmd =", and the same for us.
      vim.cmd([[autocmd WinNew * set winfixheight]])
      -- TODO when autocmd is supported on lua we can try to move this to lua properly
      vim.api.nvim_create_user_command('AccordionAutoResize', function()
        vim.cmd(
          [[execute ":AccordionAll " . string(floor(&columns/(&colorcolumn + 11)))]]
        )
      end, {})
      vim.cmd([[autocmd VimEnter,VimResized * :AccordionAutoResize]])
    end,
  },
  {
    'folke/trouble.nvim',
    dependencies = { 'kyazdani42/nvim-web-devicons' },
    config = function()
      require('trouble').setup({
        height = 20,
        padding = false,
        auto_preview = false,
        auto_close = true,
      })

      set_keymap(
        'n',
        '<LEADER>xw',
        '<CMD>Trouble workspace_diagnostics<CR>',
        { silent = true, noremap = true }
      )
      set_keymap(
        'n',
        '<LEADER>xd',
        '<CMD>Trouble document_diagnostics<CR>',
        { silent = true, noremap = true }
      )
    end,
  },
  {
    'danilamihailov/beacon.nvim',
    config = function()
      vim.g.beacon_show_jumps = 0
      vim.g.beacon_shrink = 0
      vim.g.beacon_size = 12
    end,
  },

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
    dependencies = { 'mfussenegger/nvim-dap' },
    config = function()
      require('dapui').setup()

      local dap = require('dap')

      vim.keymap.set('n', '<LEADER>dmc', function()
        dap.toggle_breakpoint()
        vim.cmd('tabnew %')
        vim.cmd('AccordionStop')
        vim.cmd([[execute "normal! \<c-o>"]])
        require('dapui').toggle({})
        dap.continue()
      end)
      vim.keymap.set('n', '<LEADER>dmx', function()
        dap.terminate()
        dap.clear_breakpoints()
        require('dapui').toggle({})
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
        require('dapui').toggle({})
      end)
    end,
  },

  {
    'j-hui/fidget.nvim',
    config = function()
      require('fidget').setup()
    end,
  },

  {
    'chipsenkbeil/distant.nvim',
    -- dev = true,
    branch = 'v0.3',
    config = function()
      require('distant'):setup({
        [''] = {
          cwd = {
            whatsapp_server = '/home/fabs/local/whatsapp/server/erl',
          },
        },
        -- ['fabs.sb.facebook.com'] = {},
        -- Applies Chip's personal settings to every machine you connect to
        -- 1. Ensures that distant servers terminate with no connections
        -- 2. Provides navigation bindings for remote directories
        -- 3. Provides keybinding to jump into a remote file's parent directory
        -- ['*'] = require('distant.settings').chip_default()
      })
    end,
  },
  {
    dir = '/usr/share/fb-editor-support/nvim',
    name = 'meta.nvim',
    dependencies = {
      'jose-elias-alvarez/null-ls.nvim',
      'neovim/nvim-lspconfig',
      'nvim-treesitter/nvim-treesitter',
      'nvim-lua/plenary.nvim',
    },
    enabled = IS_META_SERVER,
  },
}, { dev = { path = '~/Dev/nvim-plugins' } })

local function install_meta_lsp_clients()
  if IS_META_SERVER then
    require('lazy').sync()
    vim.cmd('SyncMetaLS')
  end
end

vim.api.nvim_create_user_command('SetupAndQuit', function()
  install_meta_lsp_clients()
  vim.cmd('autocmd User SyncMetaLSComplete quitall')
  vim.cmd('quitall')
end, {})

set_keymap(
  'n',
  '<LEADER>W',
  ':StripWhitespace<CR>',
  { silent = true, noremap = true }
)

set_keymap(
  'n',
  '<LEADER>hg',
  '<cmd>lua require("codehub").openURL("n")<CR>',
  { noremap = true }
)
set_keymap(
  'v',
  '<LEADER>hg',
  ':<C-U>lua require("codehub").openURL("v")<CR>',
  { noremap = true }
)
set_keymap(
  'n',
  '<LEADER>hc',
  '<cmd>lua require("codehub").copyURL("n")<CR>',
  { noremap = true }
)
set_keymap(
  'v',
  '<LEADER>hc',
  ':<C-U>lua require("codehub").copyURL("v")<CR>',
  { noremap = true }
)

vim.api.nvim_create_user_command('MetaDiffCheckout', function()
  require('meta_diff').diff_picker({ checkout = true })
end, {})
vim.api.nvim_create_user_command('MetaDiffOpenFiles', function()
  require('meta_diff').diff_picker({})
end, {})

set_keymap(
  'n',
  '<LEADER>mc',
  '<CMD>MetaDiffCheckout<CR>',
  { silent = true, noremap = true }
)
set_keymap(
  'n',
  '<LEADER>mf',
  '<CMD>MetaDiffOpenFiles<CR>',
  { silent = true, noremap = true }
)

-- starts terminal mode on insert mode
-- disables line numbers on a newly opened terminal window (not really working)
vim.cmd([[autocmd TermOpen term://* setlocal nonumber]])
-- close terminal buffer without showing the exit status of the shell
-- autocmd TermClose term://* call feedkeys("\<cr>")
-- tnoremap <Esc> <C-\><C-n>

require('slog').setup()

set_keymap(
  'n',
  '<LEADER>st',
  '<CMD>SlogToggle<CR>',
  { silent = true, noremap = true }
)

-- local function source_if_exists(file)
--   if vim.fn.filereadable(vim.fn.expand(file)) > 0 then
--     vim.cmd('source ' .. file)
--   end
-- end

-- source_if_exists(vim.env.HOME .. '/.fb-vimrc')

vim.api.nvim_create_user_command('DevReload', function(context)
  local module_names = vim.split(context.args, ' ')
  for _, module_name in ipairs(module_names) do
    package.loaded[module_name] = nil
    for name, _ in pairs(package.loaded) do
      if vim.startswith(name, module_name .. '.') then
        package.loaded[name] = nil
      end
    end
    require(module_name)
  end
end, { nargs = '?' })
