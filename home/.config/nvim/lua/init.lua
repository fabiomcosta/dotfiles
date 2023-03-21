local IS_META_SERVER = (function()
  local hostname = vim.loop.os_gethostname()
  return vim.endswith(hostname, '.fbinfra.net')
      or vim.endswith(hostname, '.facebook.com')
end)()

-- would be nice to make this async, lazy and memoized
local IS_BIGGREP_ROOT = IS_META_SERVER
    and vim.fn.system({ 'arc', 'get-config', 'project_id' }) ~= ''

local TS_PARSER_INSTALL_PATH = vim.fn.stdpath('data') .. '/site/parser'

local function identity(a1)
  return a1
end

-- See https://www.lua.org/pil/17.1.html
function memoize(fn, cache_key_gen)
  cache_key_gen = cache_key_gen or identity
  local cache = {}
  setmetatable(cache, { __mode = 'kv' })
  return function(...)
    local args = { ... }
    local cache_key = cache_key_gen(unpack(args))
    if type(cache_key) ~= 'string' then
      return error('Cache key needs to be a string.')
    end
    if cache[cache_key] == vim.NIL then
      return nil
    end
    if cache[cache_key] ~= nil then
      return cache[cache_key]
    end
    local result = fn(unpack(args))
    cache[cache_key] = result == nil and vim.NIL or result
    return result
  end
end

local function get_os_command_output(cmd, opts)
  local Job = require("plenary.job")
  opts = opts or {}
  local command = table.remove(cmd, 1)
  local stderr = {}
  local stdout, ret = Job:new({
    command = command,
    args = cmd,
    cwd = opts.cwd,
    on_stderr = function(_, data)
      table.insert(stderr, data)
    end,
  }):sync(opts.timeout)
  return stdout, ret, stderr
end

local function system(cmd, opts)
  local stdout, exit_code, stderr = get_os_command_output(cmd, opts)
  if exit_code ~= 0 then
    return error('stderr: ' .. vim.inspect(stderr) .. '\nstdout: ' .. vim.inspect(stdout))
  end
  return vim.trim(stdout[1] or '')
end

local function is_system_success(cmd, opts)
  local _, exit_code = get_os_command_output(cmd, opts)
  return exit_code == 0
end

local is_hg_repo_in_cwd = memoize(function(cwd)
  return is_system_success({ 'hg', 'root' }, { cwd = cwd })
end)

local function is_hg_repo()
  return is_hg_repo_in_cwd(vim.loop.cwd())
end

local is_biggrep_repo_in_cwd = memoize(function(cwd)
  local _, exit_code, stderr = get_os_command_output({ 'bgs' }, { cwd = cwd })
  if exit_code ~= 0 then
    return not vim.startswith(vim.trim(stderr[1]), 'Error:')
  end
  -- This is unexpected, return false
  return false
end)

local function is_biggrep_repo()
  return is_biggrep_repo_in_cwd(vim.loop.cwd())
end

local set_keymap = vim.api.nvim_set_keymap

local function replace_termcodes(str)
  return vim.api.nvim_replace_termcodes(str, true, false, true)
end

-- local function feedkeys(key, mode)
--   mode = mode or 'x'
--   vim.api.nvim_feedkeys(replace_termcodes(key), mode, false)
-- end

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

-- turn on syntax highlighting
vim.cmd([[syntax on]])

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

-- copies current buffer file path to register
vim.keymap.set('n', 'cp', function()
  local path = vim.fn.resolve(vim.fn.fnamemodify(vim.fn.expand("%"), ":~:."))
  vim.fn.setreg('+', path)
  require('osc52').copy(path)
end)

-- Keeps selection when changing indentation
-- https://github.com/mhinz/vim-galore#dont-lose-selection-when-shifting-sidewards
set_keymap('x', '<', '<gv', { noremap = true })
set_keymap('x', '>', '>gv', { noremap = true })

-- Disable cursorline highlight on insert mode
-- https://github.com/mhinz/vim-galore#smarter-cursorline
vim.cmd([[autocmd InsertLeave,WinEnter * set cursorline]])
vim.cmd([[autocmd InsertEnter,WinLeave * set nocursorline]])

local function onNeovimVSCodeSetup(use)
  use('wbthomason/packer.nvim')
  use('antoinemadec/FixCursorHold.nvim')
  use('jordwalke/VimAutoMakeDirectory')
  use('tpope/vim-git')
  use('tpope/vim-surround')
  use('tpope/vim-repeat')
  use('tpope/vim-sleuth')
  use('tpope/vim-fugitive')
  use('tpope/vim-commentary')
  use('tpope/vim-projectionist')
  use('moll/vim-node')
  -- use('jparise/vim-graphql')
  use('christoomey/vim-tmux-navigator')

  use('editorconfig/editorconfig-vim')
  use('ojroques/nvim-osc52')
  -- use 'godlygeek/tabular'
  -- use 'jeffkreeftmeijer/vim-numbertoggle'

  use('kwkarlwang/bufjump.nvim')
end

local function onPureNeovimSetup(use)
  use({ 'dracula/vim', as = 'dracula' })
  use('ntpeters/vim-better-whitespace')
  use('sheerun/vim-polyglot')
  use('othree/eregex.vim')
  use('haya14busa/incsearch.vim')
  use('rhysd/git-messenger.vim')
  use('tpope/vim-vinegar')

  -- use({
  --   'tversteeg/registers.nvim',
  --   config = function()
  --     require('registers').setup()
  --   end,
  -- })

  use({
    'nvim-treesitter/nvim-treesitter',
    run = function()
      require('nvim-treesitter.install').prefer_git = true
      require('nvim-treesitter.install').update({ with_sync = true })()

      use({
        'nvim-treesitter/nvim-treesitter-refactor',
        requires = { { 'nvim-treesitter/nvim-treesitter' } },
      })
      use({
        'windwp/nvim-ts-autotag',
        requires = { { 'nvim-treesitter/nvim-treesitter' } },
      })
      use({
        'JoosepAlviste/nvim-ts-context-commentstring',
        requires = { { 'nvim-treesitter/nvim-treesitter' } },
      })
    end,
  })

  use('onsails/lspkind-nvim')
  use('hrsh7th/vim-vsnip')
  use('rafamadriz/friendly-snippets')

  use('hrsh7th/nvim-cmp')
  use('hrsh7th/cmp-nvim-lsp')
  use('hrsh7th/cmp-buffer')
  use('hrsh7th/cmp-path')
  use('hrsh7th/cmp-cmdline')
  use('hrsh7th/cmp-vsnip')

  use('neovim/nvim-lspconfig')
  use('williamboman/mason.nvim')
  use({
    'jose-elias-alvarez/null-ls.nvim',
    requires = { { 'nvim-lua/plenary.nvim' } },
  })

  use('kkharji/lspsaga.nvim')

  use('nvim-lua/popup.nvim')
  use('nvim-telescope/telescope-fzy-native.nvim')
  use({
    'nvim-telescope/telescope.nvim',
    requires = {
      { 'nvim-lua/plenary.nvim', 'nvim-telescope/telescope-fzy-native.nvim' },
    },
  })

  use('TimUntersberger/neogit')
  use({
    'hoob3rt/lualine.nvim',
    requires = { { 'kyazdani42/nvim-web-devicons' } },
  })
  use('thaerkh/vim-workspace')
  use({
    'vim-test/vim-test',
    requires = { { 'voldikss/vim-floaterm' } },
  })
  use('mattboehm/vim-accordion')
  use({
    'folke/trouble.nvim',
    requires = { { 'kyazdani42/nvim-web-devicons' } },
  })
  use('danilamihailov/beacon.nvim')

  use('mfussenegger/nvim-dap')
  use('rcarriga/nvim-dap-ui')
  use('theHamsta/nvim-dap-virtual-text')

  use('j-hui/fidget.nvim')

  if IS_META_SERVER then
    use({ '/usr/share/fb-editor-support/nvim', as = 'meta.nvim' })
  end
end

local function onNeovimVSCodeConfig()
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

  require('bufjump').setup({
    backward = '<C-b>',
    forward = '<C-n>',
  })
  set_keymap('n', '<C-p>', '<C-w>p', { silent = true, noremap = true })
end

local function onPureNeovimConfig()
  set_keymap(
    'n',
    '<LEADER>W',
    ':StripWhitespace<CR>',
    { silent = true, noremap = true }
  )

  vim.g.javascript_plugin_flow = 1

  vim.g.eregex_default_enable = 0

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

  vim.g.git_messenger_floating_win_opts = { border = 'single' }
  vim.g.git_messenger_popup_content_margins = false
  set_keymap(
    'n',
    '<LEADER>gm',
    ':GitMessenger<CR>',
    { silent = true, noremap = false }
  )

  vim.g.netrw_liststyle = 3
  set_keymap(
    'n',
    '<LEADER>z',
    ':Vexplore<CR>',
    { silent = true, noremap = true }
  )

  vim.opt.runtimepath:append(TS_PARSER_INSTALL_PATH)
  require('nvim-treesitter.install').prefer_git = true
  require('nvim-treesitter.configs').setup({
    parser_install_dir = TS_PARSER_INSTALL_PATH,
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
    -- highlight = {
    --   enable = true,
    -- },
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

  local cmp = require('cmp')
  local lspkind = require('lspkind')

  cmp.setup({
    snippet = {
      expand = function(args)
        vim.fn['vsnip#anonymous'](args.body)
      end,
    },
    formatting = {
      format = lspkind.cmp_format(),
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

  local nvim_lsp = require('lspconfig')

  vim.api.nvim_set_keymap(
    'n',
    '[d',
    '<cmd>lua vim.diagnostic.goto_prev()<CR>',
    { silent = true, noremap = true }
  )
  vim.api.nvim_set_keymap(
    'n',
    ']d',
    '<cmd>lua vim.diagnostic.goto_next()<CR>',
    { silent = true, noremap = true }
  )

  local on_attach = function(client, bufnr)
    auto_format_on_save(client, bufnr)

    -- Use lsp find_references if its available, and fallback to a grep_string.
    if client.server_capabilities.find_references then
      set_keymap(
        'n',
        '<LEADER>fr',
        '<cmd>Telescope lsp_references<CR>',
        { silent = false, noremap = true }
      )
      -- The ideal check here is to check for biggrep support somehow
    elseif IS_BIGGREP_ROOT then
      -- Use Telescope biggrep with the current selection
      set_keymap(
        'n',
        '<LEADER>fr',
        "viw:'<,'>Bgs<CR>",
        { silent = false, noremap = true }
      )
    else
      set_keymap(
        'n',
        '<LEADER>fr',
        '<cmd>Telescope grep_string<CR>',
        { silent = false, noremap = true }
      )
    end

    local function buf_set_keymap(...)
      vim.api.nvim_buf_set_keymap(bufnr, ...)
    end

    -- Mappings.
    local opts = { noremap = true, silent = true }

    buf_set_keymap('n', 'gd', '<cmd>lua vim.lsp.buf.definition()<CR>', opts)
    buf_set_keymap(
      'n',
      '<LEADER>q',
      '<cmd>lua vim.lsp.diagnostic.set_loclist()<CR>',
      opts
    )

    -- lspsaga key bindings
    buf_set_keymap(
      'n',
      'K',
      '<cmd>lua require"lspsaga.hover".render_hover_doc()<CR>',
      opts
    )
    buf_set_keymap(
      'n',
      'gh',
      '<cmd>lua require"lspsaga.provider".preview_definition()<CR>',
      opts
    )
    buf_set_keymap(
      'n',
      'gk',
      '<cmd>lua require"lspsaga.provider".lsp_finder()<CR>',
      opts
    )
    buf_set_keymap(
      'n',
      '[d',
      '<cmd>lua require"lspsaga.diagnostic".lsp_jump_diagnostic_prev()<CR>',
      opts
    )
    buf_set_keymap(
      'n',
      ']d',
      '<cmd>lua require"lspsaga.diagnostic".lsp_jump_diagnostic_next()<CR>',
      opts
    )
    buf_set_keymap(
      'n',
      '<LEADER>e',
      '<cmd>lua require"lspsaga.diagnostic".show_line_diagnostics()<CR>',
      opts
    )
    buf_set_keymap(
      'n',
      '<LEADER>ca',
      '<cmd>lua require"lspsaga.codeaction".code_action()<CR>',
      opts
    )
    buf_set_keymap(
      'v',
      '<LEADER>ca',
      ':<C-U>lua require"lspsaga.codeaction".range_code_action()<CR>',
      opts
    )
    buf_set_keymap(
      'n',
      '<LEADER>lg',
      '<cmd>lua require"lspsaga.floaterm".open_float_terminal("lazygit")<CR>',
      opts
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

  require('mason').setup()

  -- Use a loop to conveniently call 'setup' on multiple servers and
  -- map buffer local keybindings when the language server attaches
  local servers = {}

  nvim_lsp.flow.setup(with_lsp_default_config({
    cmd = { 'flow', 'lsp' },
  }))

  if IS_META_SERVER then
    require('meta')
    require('meta.lsp')
    table.insert(servers, 'hhvm')
    table.insert(servers, 'prettier@meta')
    table.insert(servers, 'eslint@meta')
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
    table.insert(servers, 'tsserver')
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
          diagnostics = {
            -- Get the language server to recognize the `vim` global
            globals = { 'vim', 'hs' },
          },
          workspace = {
            -- Make the server aware of Neovim runtime files
            library = vim.api.nvim_get_runtime_file('', true),
          },
          -- Do not send telemetry data containing a randomized but unique identifier
          telemetry = {
            enable = false,
          },
        },
      },
    }))
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

  for _, lsp in ipairs(servers) do
    nvim_lsp[lsp].setup(with_lsp_default_config())
  end

  require('lspsaga').init_lsp_saga({
    code_action_prompt = {
      -- This was making the "lamp" icon show on the cursor's line all the time
      -- for some projects.
      enable = false,
    },
  })

  require('fidget').setup({})

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

  if IS_BIGGREP_ROOT then
    -- myles only works on hg repos
    if is_hg_repo() then
      set_keymap(
        'n',
        '<LEADER>ff',
        '<cmd>Telescope myles<CR>',
        { silent = false, noremap = true }
      )
    elseif is_biggrep_repo() then
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
    end
    set_keymap(
      'n',
      '<LEADER>fg',
      '<cmd>Telescope biggrep s<CR>',
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

  require('neogit').setup({
    disable_commit_confirmation = true,
    disable_insert_on_commit = false,
  })

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
      lualine_z = {},
    },
    inactive_sections = {
      lualine_c = { { 'filename', path = 1 } },
      lualine_x = {},
    },
  })

  vim.g.workspace_autosave = 0
  vim.g.workspace_autocreate = 1
  vim.g.workspace_session_disable_on_args = 1
  -- This plugin functionality makes no sense, it's completely unrelated from its
  -- core functionality :|
  vim.g.workspace_autosave_untrailspaces = 0
  vim.g.workspace_autosave_untrailtabs = 0

  vim.g.workspace_session_directory =
      vim.fn.expand('~/.local/share/nvim/sessions')
  vim.g.workspace_undodir =
      vim.fn.expand('~/.local/share/nvim/sessions/.undodir')

  vim.g['test#strategy'] = 'neovim'
  vim.g['test#neovim#term_position'] = 'botright 20'
  vim.g['test#neovim#start_normal'] = 1
  vim.g['test#javascript#jest#options'] = '--verbose=false'
  vim.g['test#custom_runners'] = { PHP = { 'Arc' }, JavaScript = { 'Arc' } }

  _G.fabs_test_kill_last_term_window = function()
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
      return replace_termcodes('<C-w>' .. last_window_nr .. 'c')
    end
    return ''
  end
  set_keymap(
    'n',
    '<LEADER>tk',
    -- Closes the last term window according to vim's order, so either the
    -- bottom-most or if there is none on the bottom, the last to the right.
    'v:lua.fabs_test_kill_last_term_window()',
    { silent = true, noremap = false, expr = true }
  )
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

  -- TODO is there a native lua way to do this?
  vim.cmd([[colorscheme dracula]])
  -- vim.cmd [[colorscheme tokyonight]]
  -- vim.cmd [[colorscheme dracula_pro]]

  -- starts terminal mode on insert mode
  -- disables line numbers on a newly opened terminal window (not really working)
  vim.cmd([[autocmd TermOpen term://* setlocal nonumber]])
  -- close terminal buffer without showing the exit status of the shell
  -- autocmd TermClose term://* call feedkeys("\<cr>")
  -- tnoremap <Esc> <C-\><C-n>

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

  vim.g.beacon_show_jumps = 0
  vim.g.beacon_shrink = 0
  vim.g.beacon_size = 12

  local function copy()
    if vim.v.event.operator == 'y' and vim.v.event.regname == '' then
      require('osc52').copy_register('"')
    end
  end
  vim.api.nvim_create_autocmd('TextYankPost', { callback = copy })

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

  require('slog').setup()

  set_keymap(
    'n',
    '<LEADER>st',
    '<CMD>SlogToggle<CR>',
    { silent = true, noremap = true }
  )

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

    require('dapui').setup()
    require('nvim-dap-virtual-text').setup({})

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
  end

  -- local function source_if_exists(file)
  --   if vim.fn.filereadable(vim.fn.expand(file)) > 0 then
  --     vim.cmd('source ' .. file)
  --   end
  -- end

  -- source_if_exists(vim.env.HOME .. '/.fb-vimrc')
end

local install_path = vim.fn.stdpath('data')
    .. '/site/pack/packer/start/packer.nvim'
if vim.fn.isdirectory(install_path) == 0 then
  vim.fn.system({
    'git',
    'clone',
    '--depth',
    '1',
    'https://github.com/wbthomason/packer.nvim',
    install_path,
  })
end

local packerStatus, packer = pcall(require, 'packer')
if not packerStatus then
  -- it would be nice to show a message before closing.
  vim.cmd('quitall')
end

local function setup(use)
  onNeovimVSCodeSetup(use)
  if vim.g.vscode == nil then
    onPureNeovimSetup(use)
  end
end

local function config()
  onNeovimVSCodeConfig()
  if vim.g.vscode == nil then
    onPureNeovimConfig()
  end
end

local function install_meta_lsp_clients()
  if IS_META_SERVER then
    require('meta')
    vim.cmd('SyncMetaLS')

    vim.opt.runtimepath:append(TS_PARSER_INSTALL_PATH)
    require('nvim-treesitter').setup()
    require('nvim-treesitter.install').prefer_git = true
    require('nvim-treesitter.configs').setup({
      parser_install_dir = TS_PARSER_INSTALL_PATH,
    })
    vim.cmd('TSUpdateSync')
  end
end

vim.api.nvim_create_user_command('SetupAndQuit', function()
  install_meta_lsp_clients()
  vim.cmd('quitall')
end, {})

return packer.startup({
  function(use)
    setup(use)

    -- Calls PackerSync if we get any module not found error on the
    -- config step.
    local configStatus, configError = pcall(config)
    if not configStatus and configError ~= nil then
      local isModuleNotFoundError = string.find(
            configError,
            [[module ['"][%w._-]+['"] not found:]]
          ) ~= nil
      if isModuleNotFoundError then
        -- I already setup everything on start on the meta server
        -- so only execute this otherwise
        -- if not IS_META_SERVER then
        --   vim.api.nvim_create_autocmd('User PackerComplete', {
        --     callback = function()
        --       install_meta_lsp_clients()
        --       vim.cmd('quitall')
        --     end
        --   })
        --   packer.sync()
        -- end
      else
        error(configError)
      end
    end

    vim.cmd([[filetype plugin indent on]])
  end,
  config = {
    display = {
      open_fn = function()
        return require('packer.util').float({ border = 'single' })
      end,
    },
  },
})
