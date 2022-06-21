local set_keymap = vim.api.nvim_set_keymap

local function replace_termcodes(str)
  return vim.api.nvim_replace_termcodes(str, true, false, true)
end

local function feedkeys(key, mode)
  mode = mode or 'x'
  vim.api.nvim_feedkeys(replace_termcodes(key), mode, false)
end

local function starts_with(str, start)
  return str:sub(1, #start) == start
end

local function ends_with(str, ending)
  return ending == '' or str:sub(- #ending) == ending
end

local function trim(str)
  return str:match('^%s*(.*%S)') or ''
end

local hostname = vim.loop.os_gethostname()
local IS_META_SERVER = ends_with(hostname, '.fbinfra.net')
    or ends_with(hostname, '.facebook.com')

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
  '*.so',
  '*.dll',
  '*.exe',
  '*.zip',
  '*.tar',
  '*.gz',
  '*.swf',
  '*.swp',
  '*.swo',
  '*~',
  '*.pyc',
  '*.psd',
  '*.png',
  '*.gif',
  '*.jpeg',
  '*.jpg',
  '*.pdf',
  '*/.git/*',
  '*/.hq/*',
  '*/.svn/*',
  '*/tmp/*',
  '*/.sass-cache/*',
  '*/.yarn-cache/*',
  '*/submodules/*',
  '*/custom_modules/*',
  'tags',
  '*.i',
  '*.d',
  '*.sql3', -- other exotic extensions
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
set_keymap(
  'n',
  'cp',
  ':let @+ = resolve(fnamemodify(expand("%"), ":~:.")) | :OSCYankReg +<CR>',
  { noremap = true }
)

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
  use({ 'styled-components/vim-styled-components', branch = 'main' })
  use('moll/vim-node')
  -- use('hhvm/vim-hack')
  -- use('jparise/vim-graphql')
  use('christoomey/vim-tmux-navigator')

  use('editorconfig/editorconfig-vim')
  use('ojroques/vim-oscyank')
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

  use('tversteeg/registers.nvim')

  use({ 'nvim-treesitter/nvim-treesitter', run = ':TSUpdate' })
  use('windwp/nvim-ts-autotag')
  use('nvim-treesitter/nvim-treesitter-refactor')

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
  use('williamboman/nvim-lsp-installer')
  use('JoosepAlviste/nvim-ts-context-commentstring')
  use({
    'jose-elias-alvarez/null-ls.nvim',
    requires = { { 'nvim-lua/plenary.nvim' } },
  })

  use('tami5/lspsaga.nvim')

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
  use('chipsenkbeil/distant.nvim')

  if IS_META_SERVER then
    use { "/usr/share/fb-editor-support/nvim", as = "meta.nvim", run = ':SyncMetaLS' }
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
    ['.arcconfig'] = vim.tbl_deep_extend("keep", {
      ['**/__tests__/*Test.php'] = {
        alternate = '{}.php',
        type = 'test',
      },
      ['*.php'] = {
        alternate = '{dirname}/__tests__/{basename}Test.php',
        type = 'source',
      },
    }, jest_alternate)
  }

  require('bufjump').setup()
  set_keymap(
    'n',
    '<C-p>',
    ':lua require("bufjump").backward()<CR>',
    { silent = true, noremap = true }
  )
  set_keymap(
    'n',
    '<C-n>',
    ':lua require("bufjump").forward()<CR>',
    { silent = true, noremap = true }
  )
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
      -- 'vim',
      'hack',
    },
    highlight = {
      enable = true,
    },
    indent = {
      enable = false,
    },
    autotag = {
      enable = true,
    },
    context_commentstring = {
      enable = true,
    },
    refactor = {
      highlight_definitions = { enable = true },
      smart_rename = {
        enable = true,
        keymaps = {
          smart_rename = '<LEADER>rn',
        },
      },
    },
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

  local auto_format_on_save = function(client)
    if client.resolved_capabilities.document_formatting then
      vim.cmd([[
        augroup Format
          autocmd! * <buffer>
          autocmd BufWritePre <buffer> lua vim.lsp.buf.formatting_sync(nil, 2000)
        augroup END
      ]])
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
    auto_format_on_save(client)

    -- Use lsp find_references if its available, and fallback to a grep_string.
    if client.resolved_capabilities.find_references then
      set_keymap(
        'n',
        '<LEADER>fr',
        '<cmd>Telescope lsp_references<CR>',
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

  local capabilities = require('cmp_nvim_lsp').update_capabilities(
    vim.lsp.protocol.make_client_capabilities()
  )

  local function with_lsp_default_config(config)
    return vim.tbl_deep_extend("keep", config or {}, {
      on_attach = on_attach,
      capabilities = capabilities,
      flags = {
        debounce_text_changes = 150,
      },
    })
  end

  require('nvim-lsp-installer').setup({})

  -- Use a loop to conveniently call 'setup' on multiple servers and
  -- map buffer local keybindings when the language server attaches
  local servers = {}

  if IS_META_SERVER then
    require('meta')
    require('meta.lsp')
    table.insert(servers, 'hhvm')
    table.insert(servers, 'eslint@meta')
    table.insert(servers, 'prettier@meta')
    nvim_lsp.flow.setup(with_lsp_default_config({
      cmd = { 'flow', 'lsp' },
    }))
  else
    table.insert(servers, 'flow')
    nvim_lsp.eslint.setup(with_lsp_default_config({
      on_attach = function(client, bufnr)
        -- neovim's LSP client does not currently support dynamic capabilities registration, so we need to set
        -- the resolved capabilities of the eslint server ourselves!
        client.resolved_capabilities.document_formatting = true
        on_attach(client, bufnr)
      end,
      settings = {
        format = { enable = true }, -- this will enable formatting
      },
    }))
    nvim_lsp.sumneko_lua.setup(with_lsp_default_config({
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
      }
    }))
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
        '--trim', -- add this value
      },
    }
  end
  require('telescope').setup(telescope_setup)
  require('telescope').load_extension('fzy_native')

  set_keymap(
    'n',
    '<LEADER>ff',
    '<cmd>Telescope find_files<CR>',
    { silent = false, noremap = true }
  )
  set_keymap(
    'n',
    '<LEADER>fh',
    '<cmd>Telescope find_files hidden=true<CR>',
    { silent = false, noremap = true }
  )
  set_keymap(
    'n',
    '<LEADER>fg',
    '<cmd>Telescope live_grep<CR>',
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
      lualine_z = {}
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

  vim.g.workspace_session_directory = vim.fn.expand(
    '~/.local/share/nvim/sessions'
  )
  vim.g.workspace_undodir = vim.fn.expand(
    '~/.local/share/nvim/sessions/.undodir'
  )

  vim.g['test#strategy'] = 'neovim'
  vim.g['test#neovim#term_position'] = 'botright 20'
  vim.g['test#neovim#start_normal'] = 1
  vim.g['test#custom_runners'] = {PHP = {'Arc'}, JavaScript = {'Arc'}}

  _G.fabs_test_kill_last_term_window = function()
    -- get buffer name from last windows
    local last_window_index = vim.fn.winnr('$')
    local last_buffer_name = vim.fn.bufname(vim.fn.winbufnr(last_window_index))
    if starts_with(last_buffer_name, 'term://') then
      return replace_termcodes('<C-w>' .. last_window_index .. 'c')
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
  vim.cmd(
    [[autocmd VimEnter,VimResized * execute ":AccordionAll " . string(floor(&columns/(&colorcolumn + 11)))]]
  )

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

  require('distant').setup({
    -- Applies Chip's personal settings to every machine you connect to
    --
    -- 1. Ensures that distant servers terminate with no connections
    -- 2. Provides navigation bindings for remote directories
    -- 3. Provides keybinding to jump into a remote file's parent directory
    ['*'] = require('distant.settings').chip_default(),
  })

  vim.cmd([[
    autocmd TextYankPost * if v:event.operator is 'y' && v:event.regname is '' | execute 'OSCYankReg "' | endif
  ]])

  local function source_if_exists(file)
    if vim.fn.filereadable(vim.fn.expand(file)) > 0 then
      vim.cmd('source ' .. file)
    end
  end

  source_if_exists(vim.env.HOME .. '/.fb-vimrc')

  if IS_META_SERVER then

    local function checkout_diff(diff_id)
      local checkout_output = vim.fn.system({
        'hg',
        'checkout',
        diff_id
      })
      if vim.v.shell_error ~= 0 then
        return error(checkout_output)
      end
    end

    local function open_diff_files(diff_id)
      local diff_file_list = vim.fn.systemlist({
        'hg',
        'status',
        '--no-status',
        '--color=never',
        '--added',
        '--modified',
        '--change',
        diff_id,
      })
      for _, file_path in ipairs(diff_file_list) do
        vim.cmd('vsplit')
        feedkeys('<C-w>l')
        vim.cmd('e ' .. file_path)
      end
    end

    vim.api.nvim_create_user_command(
      'MetaDiffWork',
      function(opts)
        local diff_id = opts.args
        checkout_diff(diff_id)
        open_diff_files(diff_id)
      end,
      { nargs = 1 }
    )
    vim.api.nvim_create_user_command(
      'MetaDiffOpenFiles',
      function(opts)
        local diff_id = opts.args
        open_diff_files(diff_id)
      end,
      { nargs = 1 }
    )
  end

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

return packer.startup({
  function(use)
    setup(use)

    -- Calls PackerSync if we get any module not found error on the
    -- config step.
    local configStatus, configError = pcall(config)
    if not configStatus then
      local isModuleNotFoundError = string.find(
        configError,
        [[module ['"][%w_-]+['"] not found:]]
      ) ~= nil
      if isModuleNotFoundError then
        vim.cmd([[autocmd User PackerComplete quitall]])
        packer.sync()
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
