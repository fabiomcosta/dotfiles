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

-- Unless any plugin requires these, there is no reason for them to polute
-- the checkhealth screen with confusing warnings.
vim.g.loaded_node_provider = 0
vim.g.loaded_perl_provider = 0
vim.g.loaded_python3_provider = 0
vim.g.loaded_ruby_provider = 0

-- avoiding possible issues on plugins that are generaly only tested on bash.
vim.opt.shell = 'bash'
-- vim can merge signcolumn and number column into one
vim.opt.signcolumn = 'number'

-- adds possibility of using 256 colors
vim.opt.termguicolors = true

-- only show file name on tabs
vim.opt.showtabline = 0

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

-- Keeps selection when changing indentation
-- https://github.com/mhinz/vim-galore#dont-lose-selection-when-shifting-sidewards
set_keymap('x', '<', '<gv', { noremap = true })
set_keymap('x', '>', '>gv', { noremap = true })

-- Disable cursorline highlight on insert mode
-- https://github.com/mhinz/vim-galore#smarter-cursorline
vim.cmd([[autocmd InsertLeave,WinEnter * set cursorline]])
vim.cmd([[autocmd InsertEnter,WinLeave * set nocursorline]])

local function copy_to_clipboard(str)
  vim.fn.setreg('+', str)
  utils.require_if_exists('osc52', function(osc52)
    osc52.copy(str)
  end)
end

-- copies current buffer file path relative to cwd to register
vim.keymap.set('n', 'cp', function()
  local path = vim.fn.resolve(vim.fn.fnamemodify(vim.fn.expand('%'), ':~:.'))
  copy_to_clipboard(path)
end)

-- copies current buffer filename to register
vim.keymap.set('n', 'cf', function()
  local filename = vim.fn.resolve(vim.fn.fnamemodify(vim.fn.expand('%'), ':t'))
  copy_to_clipboard(filename)
end)

vim.filetype.add({
  extension = {
    php = function(_path, bufnr)
      if vim.startswith(vim.filetype.getlines(bufnr, 1), '<?hh') then
        return 'hack',
            function(_bufnr)
              vim.opt_local.syntax = 'php'
              vim.opt_local.iskeyword:append('$')
            end
      end
      return 'php'
    end,
    -- js = function(_path, bufnr)
    --   for _, line in ipairs(vim.filetype.getlines(bufnr, 1, 16)) do
    --     if string.find(line, '@flow') then
    --       return 'flow'
    --     end
    --   end
    --   return 'javascript'
    -- end,
  },
  pattern = {
    ['.*%.js.flow'] = 'javascript',
  },
})

local lazypath = utils.joinpath(vim.fn.stdpath('data'), 'lazy', 'lazy.nvim')
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
  { 'antoinemadec/FixCursorHold.nvim' },
  { 'jordwalke/VimAutoMakeDirectory' },
  { 'tpope/vim-git' },
  { 'tpope/vim-surround' },
  { 'tpope/vim-repeat' },
  { 'tpope/vim-fugitive' },
  { 'moll/vim-node' },
  { 'christoomey/vim-tmux-navigator' },
  { 'ntpeters/vim-better-whitespace' },
  -- { 'jparise/vim-graphql' },
  -- { 'godlygeek/tabular' },
  -- { 'jeffkreeftmeijer/vim-numbertoggle' },

  -- TO BE DEPRECATED ONCE 0.10 is available in all envs I work on
  { 'editorconfig/editorconfig-vim' },
  { 'tpope/vim-commentary' },
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
  -- END DEPRECATED

  {
    'othree/eregex.vim',
    config = function()
      vim.g.eregex_default_enable = 0
    end,
  },
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
  {
    'folke/noice.nvim',
    dependencies = {
      'MunifTanjim/nui.nvim',
      'rcarriga/nvim-notify',
    },
    event = 'VeryLazy',
    config = function()
      require('notify').setup({
        stages = vim.env.SSH_CLIENT ~= nil and "static" or "fade_in_slide_out",
      })
      require('noice').setup({
        lsp = {
          -- override markdown rendering so that **cmp** and other plugins use **Treesitter**
          override = {
            ['vim.lsp.util.convert_input_to_markdown_lines'] = true,
            ['vim.lsp.util.stylize_markdown'] = true,
            ['cmp.entry.get_documentation'] = true, -- requires hrsh7th/nvim-cmp
          },
        },
        presets = {
          lsp_doc_border = true, -- add a border to hover docs and signature help
        },
      })
    end,
  },
  {
    -- This plugin already constains 'tpope/vim-sleuth'
    'sheerun/vim-polyglot',
    init = function()
      vim.g.polyglot_disabled = { 'ftdetect', 'sensible' }
    end,
    config = function()
      vim.g.javascript_plugin_flow = 1
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
    'nvim-treesitter/nvim-treesitter',
    build = function()
      require('nvim-treesitter.install').prefer_git = true
      require('nvim-treesitter.install').update({ with_sync = true })()
    end,
    config = function()
      require('nvim-treesitter.install').prefer_git = true
      require('nvim-treesitter.configs').setup({
        sync_install = true,
        parser_install_dir = vim.fn.stdpath('data') .. '/site',
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
          'vim',
          'regex',
          'markdown',
          'markdown_inline',
        },
        highlight = {
          enable = true,
          disable = { 'c' },
        },
        indent = {
          enable = true,
          disable = { 'c' },
        },
        autotag = {
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
    config = function()
      require('ts_context_commentstring').setup({
        languages = {
          hack = require('ts_context_commentstring.config').config.languages.php,
        },
      })
    end,
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
      'nvimdev/lspsaga.nvim',
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
        buf_set_keymap('n', 'gh', '<CMD>Lspsaga peek_definition<CR>')
        buf_set_keymap('n', 'gk', '<CMD>Lspsaga finder<CR>')
        buf_set_keymap(
          'n',
          '<LEADER>e',
          '<CMD>Lspsaga show_line_diagnostics<CR>'
        )
        buf_set_keymap('n', '<LEADER>ca', '<CMD>Lspsaga code_action<CR>')
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
        if installed_extensions['nuclide.erlang'] then
          table.insert(servers, 'erlang@meta')
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
            -- neovim's LSP client does not currently support dynamic capabilities
            -- registration, so we need to set the server capabilities of the
            -- eslint server ourselves!
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
    'nvimdev/lspsaga.nvim',
    config = function()
      require('lspsaga').setup({
        symbol_in_winbar = { enable = true },
        lightbulb = { enable = false },
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
        if utils.is_myles_repo() then
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
    'hoob3rt/lualine.nvim',
    dependencies = {
      'kyazdani42/nvim-web-devicons',
    },
    config = function()
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
        },
        inactive_sections = {
          lualine_c = { { 'filename', path = 1 } },
          lualine_x = {},
        },
      })
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
  -- {
  --   'mfussenegger/nvim-dap',
  --   dependencies = { 'meta.nvim' },
  --   config = function()
  --     if not utils.module_exists('meta') then
  --       return
  --     end

  --     local dap = require('dap')

  --     local meta_util = require('meta.util')
  --     local meta_lsp = require('meta.lsp')
  --     local binary_folder = meta_util.get_first_matching_dir(
  --       meta_lsp.VSCODE_EXTS_INSTALL_DIR .. '/nuclide.hhvm*'
  --     )
  --     -- hhvm has been buggy to install lately... to avoid errors on startup
  --     -- let's do this check while I figure out what is gong on there.
  --     if binary_folder ~= nil then
  --       dap.adapters.hhvm = {
  --         type = 'executable',
  --         command = meta_lsp.NODE_BINARY,
  --         args = { binary_folder .. '/src/hhvmWrapper.js' },
  --       }
  --       dap.configurations.hack = {
  --         {
  --           type = 'hhvm',
  --           name = 'Attach to hhvm process',
  --           request = 'attach',
  --           action = 'attach',
  --           debugPort = 8999,
  --           -- not sure how this is used yet... but I know
  --           -- it's supposed to be either a nuclide:// or file:// uri.
  --           -- The core attach debugger functionality works just
  --           -- fine with it being an empty string.
  --           targetUri = '',
  --         },
  --       }
  --       dap.configurations.php = dap.configurations.hack
  --     end
  --   end,
  -- },
  -- {
  --   'theHamsta/nvim-dap-virtual-text',
  --   dependencies = {
  --     'mfussenegger/nvim-dap',
  --     'nvim-treesitter/nvim-treesitter',
  --   },
  --   config = function()
  --     require('nvim-dap-virtual-text').setup({})
  --   end,
  -- },
  -- {
  --   'rcarriga/nvim-dap-ui',
  --   dependencies = { 'mfussenegger/nvim-dap', 'nvim-neotest/nvim-nio' },
  --   config = function()
  --     require('dapui').setup()

  --     local dap = require('dap')

  --     vim.keymap.set('n', '<LEADER>dmc', function()
  --       dap.toggle_breakpoint()
  --       vim.cmd('tabnew %')
  --       vim.cmd('AccordionStop')
  --       vim.cmd([[execute "normal! \<c-o>"]])
  --       require('dapui').toggle({})
  --       dap.continue()
  --     end)
  --     vim.keymap.set('n', '<LEADER>dmx', function()
  --       dap.terminate()
  --       dap.clear_breakpoints()
  --       require('dapui').toggle({})
  --       vim.cmd('tabclose')
  --       vim.cmd('AccordionAutoResize')
  --     end)
  --     vim.keymap.set('n', '<LEADER>dc', dap.continue)
  --     vim.keymap.set('n', '<LEADER>dn', dap.step_over)
  --     vim.keymap.set('n', '<LEADER>di', dap.step_into)
  --     vim.keymap.set('n', '<LEADER>do', dap.step_out)
  --     vim.keymap.set('n', '<LEADER>dbt', dap.toggle_breakpoint)
  --     vim.keymap.set('n', '<LEADER>dbc', dap.clear_breakpoints)
  --     vim.keymap.set('n', '<LEADER>dbl', dap.list_breakpoints)
  --     vim.keymap.set('n', '<LEADER>dh', function()
  --       require('dapui').eval()
  --     end)
  --     vim.keymap.set('n', '<LEADER>du', function()
  --       require('dapui').toggle({})
  --     end)
  --   end,
  -- },

  {
    'j-hui/fidget.nvim',
    config = function()
      require('fidget').setup()
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
    config = function()
      require('meta')
    end
  },
}, { dev = { path = '~/Dev/nvim-plugins' } })

vim.api.nvim_create_user_command('SetupAndQuit', function()
  if not IS_META_SERVER then
    return
  end

  local group = vim.api.nvim_create_augroup('SetupAndQuit', {})
  vim.api.nvim_create_autocmd('User', {
    group = group,
    pattern = 'SyncMetaLSComplete',
    callback = function()
      vim.cmd('quitall')
    end,
  })
  vim.api.nvim_create_autocmd('User', {
    group = group,
    pattern = 'LazySync',
    callback = function()
      vim.cmd('SyncMetaLS')
    end,
  })
  require('lazy').sync()
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

vim.api.nvim_create_user_command('GitOpenActiveFiles', function()
  local file_paths = utils.get_os_command_output({
    'git',
    'diff',
    '--relative', -- prints paths relative to CWD
    '--name-only',
    '--diff-filter=AM',
  })
  for _, name in ipairs(file_paths) do
    vim.cmd('vsplit | e ' .. name)
  end
end, {})

set_keymap(
  'n',
  '<LEADER>om', -- open modified [files]
  '<CMD>GitOpenActiveFiles<CR>',
  { silent = true, noremap = true }
)

require('keyword_case').setup()

set_keymap(
  'n',
  '<LEADER>cc',
  '<CMD>CodeCycleCase<CR>',
  { silent = true, noremap = true }
)

require('micro_sessions').setup({
  directory = utils.joinpath(vim.fn.stdpath('data'), 'session'),
})

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
