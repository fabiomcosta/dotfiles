
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
vim.opt.scrolloff = 8
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
vim.opt.backspace = {'indent', 'eol', 'start'}
-- font line-height
vim.opt.linespace = 0
-- adds line numbers to the left
vim.opt.number = true
-- prevents delay while pressing esc on insert mode
vim.opt.timeoutlen = 5000
vim.opt.ttimeoutlen = 0
-- uses OS clipboard if possible (check +clipboard)
vim.opt.clipboard:append({'unnamed', 'unnamedplus'})
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
vim.opt.wildmode = {'longest', 'full'}
-- ignored files while searching files and stuff
vim.opt.wildignore = {
  '*.so','*.dll','*.exe','*.zip','*.tar','*.gz','*.swf',
  '*.swp', '*.swo', '*~', '*.pyc',
  '*.psd', '*.png', '*.gif', '*.jpeg', '*.jpg', '*.pdf',
  '*/.git/*', '*/.hq/*', '*/.svn/*', '*/tmp/*',
  '*/.sass-cache/*',
  '*/submodules/*', '*/custom_modules/*',
  'tags',
  '*.i', '*.d', '*.sql3', -- other exotic extensions
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
vim.opt.listchars = {tab='▸\\ ', eol='¬'}
-- folding options
vim.opt.foldmethod = 'indent'
vim.opt.foldenable = false

vim.opt.jumpoptions:append({'stack'})

vim.opt.completeopt = {'menu', 'menuone', 'noselect'}

-- turn on syntax highlighting
vim.cmd [[syntax on]]

vim.api.nvim_set_keymap('n', 'j', 'gj', {noremap=true})
vim.api.nvim_set_keymap('n', 'k', 'gk', {noremap=true})

-- moves cursor faster
vim.api.nvim_set_keymap('n', '<DOWN>', '12j', {noremap=true})
vim.api.nvim_set_keymap('v', '<DOWN>', '12j', {noremap=true})
vim.api.nvim_set_keymap('n', '<UP>', '12k', {noremap=true})
vim.api.nvim_set_keymap('v', '<UP>', '12k', {noremap=true})

vim.api.nvim_set_keymap('i', 'jj', '<ESC>', {noremap=true})
vim.api.nvim_set_keymap('n', ';', ':', {noremap=true})
vim.api.nvim_set_keymap('v', ';', ':', {noremap=true})

-- makes ctrl-v work on command-line and search modes
vim.api.nvim_set_keymap('c', '<C-v>', '<C-r>"', {noremap=true})
vim.api.nvim_set_keymap('s', '<C-v>', '<C-r>"', {noremap=true})

local currentFilePath = debug.getinfo(1).source:sub(2)
vim.api.nvim_set_keymap('n', '<LEADER>ev', ':e ' .. currentFilePath .. '<CR>', {noremap=true})
vim.api.nvim_set_keymap('n', '<LEADER>\\', ':vsplit<CR><C-w>l', {noremap=true})
vim.api.nvim_set_keymap('n', '<LEADER>-', ':split<CR><C-w>j', {noremap=true})

-- changes the size of the buffer windows
vim.api.nvim_set_keymap('n', '=', '<C-w>=', {noremap=true})
vim.api.nvim_set_keymap('n', '+', ':vertical resize +5<CR>', {noremap=true})
vim.api.nvim_set_keymap('n', '-', ':vertical resize -5<CR>', {noremap=true})

-- tab related mappings
vim.api.nvim_set_keymap('n', '<LEADER>tc', ':tabnew<CR>', {noremap=true})
vim.api.nvim_set_keymap('n', '<LEADER>tp', ':tabprevious<CR>', {noremap=true})
vim.api.nvim_set_keymap('n', '<LEADER>tn', ':tabnext<CR>', {noremap=true})

-- avoid going on ex mode
vim.api.nvim_set_keymap('n', 'Q', '<NOP>', {noremap=true})

-- copies current buffer file path to register
vim.api.nvim_set_keymap('n', 'cp', ':let @+=resolve(fnamemodify(expand("%"), ":~:."))<CR>', {noremap=true})

-- Keeps selection when changing indentation
-- https://github.com/mhinz/vim-galore#dont-lose-selection-when-shifting-sidewards
vim.api.nvim_set_keymap('x', '<', '<gv', {noremap=true})
vim.api.nvim_set_keymap('x', '>', '>gv', {noremap=true})

-- Disable cursorline highlight on insert mode
-- https://github.com/mhinz/vim-galore#smarter-cursorline
vim.cmd [[autocmd InsertLeave,WinEnter * set cursorline]]
vim.cmd [[autocmd InsertEnter,WinLeave * set nocursorline]]


-- so vim won't force pep8 on all python files
vim.g.python_recommended_style = 0

local function onNeovimVSCode(use)
  use 'wbthomason/packer.nvim'
  use 'jordwalke/VimAutoMakeDirectory'
  use 'tpope/vim-surround'
  use 'tpope/vim-repeat'
  use 'tpope/vim-sleuth'
  use 'tpope/vim-fugitive'
  use 'tpope/vim-commentary'
  use {'styled-components/vim-styled-components', branch='main'}
  use 'moll/vim-node'
  use 'hhvm/vim-hack'
  use 'jparise/vim-graphql'
  use 'christoomey/vim-tmux-navigator'
  use 'editorconfig/editorconfig-vim'
  use 'ojroques/vim-oscyank'
  -- use 'godlygeek/tabular'
  -- use 'jeffkreeftmeijer/vim-numbertoggle'


  use 'tpope/vim-projectionist'
  vim.api.nvim_set_keymap('n', '<LEADER>a', ':A<CR>', { silent=true, noremap=true })
  vim.g.projectionist_heuristics = {
    ['jest.config.js|jest.config.ts']= {
      ['**/__tests__/*.test.js']= {
        alternate='{}.js',
        type='test'
      },
      ['*.js']= {
        alternate='{dirname}/__tests__/{basename}.test.js',
        type='source'
      }
    }
  }
end


local function onPureNeovim(use)

  use {'dracula/vim', as='dracula'}
  -- use 'folke/tokyonight.nvim'
  -- use '~/gdrive/code/dracula-pro/themes/vim'
  -- vim.g.dracula_colorterm = 0


  use 'ntpeters/vim-better-whitespace'
  vim.api.nvim_set_keymap('n', '<LEADER>W', ':StripWhitespace<CR>', {silent=true, noremap=true})


  use 'sheerun/vim-polyglot'
  vim.g.javascript_plugin_flow = 1


  use 'othree/eregex.vim'
  vim.g.eregex_default_enable = 0


  use 'haya14busa/incsearch.vim'
  vim.opt.hlsearch = true
  vim.g['incsearch#auto_nohlsearch'] = 1
  vim.api.nvim_set_keymap('', '/', '<Plug>(incsearch-forward)', {noremap=false})
  vim.api.nvim_set_keymap('', 'n', '<Plug>(incsearch-nohl-n)', {noremap=false})
  vim.api.nvim_set_keymap('', 'N', '<Plug>(incsearch-nohl-N)', {noremap=false})
  vim.api.nvim_set_keymap('', '*', '<Plug>(incsearch-nohl-*)', {noremap=false})
  vim.api.nvim_set_keymap('', '#', '<Plug>(incsearch-nohl-#)', {noremap=false})
  vim.api.nvim_set_keymap('', 'g*', '<Plug>(incsearch-nohl-g*)', {noremap=false})
  vim.api.nvim_set_keymap('', 'g#', '<Plug>(incsearch-nohl-g#)', {noremap=false})
  vim.api.nvim_set_keymap('', '<LEADER>/', '<Plug>(incsearch-forward)<C-r><C-w><CR>', {noremap=false})


  use 'rhysd/git-messenger.vim'
  vim.g.git_messenger_floating_win_opts = { border='single' }
  vim.g.git_messenger_popup_content_margins = false
  vim.api.nvim_set_keymap('n', '<LEADER>gm', ':GitMessenger<CR>', {silent=true, noremap=false})


  use 'tpope/vim-vinegar'
  vim.g.netrw_liststyle = 3
  vim.api.nvim_set_keymap('n', '<LEADER>z', ':Vexplore<CR>', {silent=true, noremap=true})


  use 'tversteeg/registers.nvim'


  -- function! CocAfterUpdate(info)
  --   CocInstall coc-prettier
  -- endfunction
  use {'neoclide/coc.nvim', branch='release'}


  use 'kwkarlwang/bufjump.nvim'
  require('bufjump').setup()
  vim.api.nvim_set_keymap('n', '<C-p>', ':lua require("bufjump").backward()<CR>', {silent=true, noremap=true})
  vim.api.nvim_set_keymap('n', '<C-n>', ':lua require("bufjump").forward()<CR>', {silent=true, noremap=true})


  use {'nvim-treesitter/nvim-treesitter', run=':TSUpdate'}
  use 'windwp/nvim-ts-autotag'
  use 'nvim-treesitter/nvim-treesitter-refactor'
  require('nvim-treesitter.configs').setup({
    ensure_installed = {'javascript', 'typescript', 'tsx', 'lua', 'html', 'fish', 'json', 'yaml', 'scss', 'css', 'python', 'bash', 'erlang', 'graphql', 'vim'},
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
      enable = true
    },
    refactor = {
      highlight_definitions = { enable = true },
      smart_rename = {
        enable = true,
        keymaps = {
          smart_rename = 'grr',
        },
      },
    },
  })
  local parser_config = require 'nvim-treesitter.parsers'.get_parser_configs()
  parser_config.tsx.used_by = 'javascript'


  use 'onsails/lspkind-nvim'
  use 'hrsh7th/vim-vsnip'
  use 'rafamadriz/friendly-snippets'

  use 'hrsh7th/nvim-cmp'
  use 'hrsh7th/cmp-nvim-lsp'
  use 'hrsh7th/cmp-buffer'
  use 'hrsh7th/cmp-path'
  use 'hrsh7th/cmp-cmdline'
  use 'hrsh7th/cmp-vsnip'

  local cmp = require('cmp')
  local lspkind = require('lspkind')

  local feedkey = function(key, mode)
    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(key, true, true, true), mode, true)
  end

  cmp.setup({
    snippet = {
      expand = function(args)
        vim.fn["vsnip#anonymous"](args.body)
      end,
    },
    formatting = {
      format = lspkind.cmp_format(),
    },
    mapping = {
      ['<C-b>'] = cmp.mapping(cmp.mapping.scroll_docs(-4), {'i', 'c'}),
      ['<C-f>'] = cmp.mapping(cmp.mapping.scroll_docs(4), {'i', 'c'}),
      ['<C-Space>'] = cmp.mapping(cmp.mapping.complete(), {'i', 'c'}),
      ['<C-y>'] = cmp.config.disable, -- Specify `cmp.config.disable` if you want to remove the default `<C-y>` mapping.
      ['<C-e>'] = cmp.mapping({
        i = cmp.mapping.abort(),
        c = cmp.mapping.close(),
      }),
      -- Accept currently selected item. If none selected, `select` first item.
      -- Set `select` to `false` to only confirm explicitly selected items.
      ['<CR>'] = cmp.mapping.confirm({select = true}),
      ['<Tab>'] = cmp.mapping(function(fallback)
        if vim.fn["vsnip#available"](1) == 1 then
          return feedkey("<Plug>(vsnip-expand-or-jump)", "")
        end
        fallback()
      end, {'i', 's'}),
      ['<S-Tab>'] = cmp.mapping(function(fallback)
        if vim.fn["vsnip#jumpable"](-1) == 1 then
          return feedkey("<Plug>(vsnip-jump-prev)", "")
        end
        fallback()
      end, {'i', 's'}),
    },
    documentation = {
      border = { '╭', '─', '╮', '│', '╯', '─', '╰', '│' },
    },
    sources = {
      {name = 'nvim_lsp'},
      {name = 'vsnip'},
      {name = 'buffer'},
    },
  })


  use 'neovim/nvim-lspconfig'
  use 'williamboman/nvim-lsp-installer'
  use 'JoosepAlviste/nvim-ts-context-commentstring'


  local nvim_lsp = require('lspconfig')

  -- Use an on_attach function to only map the following keys
  -- after the language server attaches to the current buffer
  local on_attach = function(client, bufnr)
    local function buf_set_keymap(...) vim.api.nvim_buf_set_keymap(bufnr, ...) end

    if client.resolved_capabilities.document_formatting then
      vim.cmd [[
        augroup Format
          autocmd! * <buffer>
          autocmd BufWritePre <buffer> lua vim.lsp.buf.formatting_sync()
        augroup END
      ]]
    end

    -- Use lsp find_references if its available, and fallback to a grep_string.
    if client.resolved_capabilities.find_references then
      vim.api.nvim_set_keymap('n', '<LEADER>fr', '<cmd>Telescope lsp_references<CR>', {silent=false, noremap=true})
    else
      vim.api.nvim_set_keymap('n', '<LEADER>fr', '<cmd>Telescope grep_string<CR>', {silent=false, noremap=true})
    end

    -- Mappings.
    local opts = {noremap=true, silent=true}

    buf_set_keymap('n', 'gd', '<cmd>lua vim.lsp.buf.definition()<CR>', opts)
    buf_set_keymap('n', '<LEADER>q', '<cmd>lua vim.lsp.diagnostic.set_loclist()<CR>', opts)

    -- lspsaga key bindings
    buf_set_keymap('n', 'K', '<cmd>lua require"lspsaga.hover".render_hover_doc()<CR>', opts)
    buf_set_keymap('n', 'gh', '<cmd>lua require"lspsaga.provider".preview_definition()<CR>', opts)
    buf_set_keymap('n', 'gk', '<cmd>lua require"lspsaga.provider".lsp_finder()<CR>', opts)
    buf_set_keymap('n', '[d', '<cmd>lua require"lspsaga.diagnostic".lsp_jump_diagnostic_prev()<CR>', opts)
    buf_set_keymap('n', ']d', '<cmd>lua require"lspsaga.diagnostic".lsp_jump_diagnostic_next()<CR>', opts)
    buf_set_keymap('n', '<LEADER>e', '<cmd>lua require"lspsaga.diagnostic".show_line_diagnostics()<CR>', opts)
    buf_set_keymap('n', '<LEADER>rn', '<cmd>lua require"lspsaga.rename".rename()<CR>', opts)
    buf_set_keymap('n', '<LEADER>ca', '<cmd>lua require"lspsaga.codeaction".code_action()<CR>', opts)
    buf_set_keymap('v', '<LEADER>ca', ':<C-U>lua require"lspsaga.codeaction".range_code_action()<CR>', opts)
    buf_set_keymap('n', '<LEADER>lg', '<cmd>lua require"lspsaga.floaterm".open_float_terminal("lazygit")<CR>', opts)

  end

  local capabilities = require('cmp_nvim_lsp')
    .update_capabilities(vim.lsp.protocol.make_client_capabilities())

  -- Use a loop to conveniently call 'setup' on multiple servers and
  -- map buffer local keybindings when the language server attaches
  local servers = {'flow'}
  for _, lsp in ipairs(servers) do
    nvim_lsp[lsp].setup({
      capabilities = capabilities,
      on_attach = on_attach,
      flags = {
        debounce_text_changes = 150,
      }
    })
  end
  -- nvim_lsp.flow.setup {
  --   cmd = { 'npx', '--no-install', '--package', 'flow-bin', 'flow', 'lsp', '>', '||', 'flow', 'lsp' },
  --   on_attach = on_attach,
  --   flags = {
  --     debounce_text_changes = 150,
  --   }
  -- }

  local lsp_installer = require('nvim-lsp-installer')
  lsp_installer.on_server_ready(function(server)
    local opts = {
      capabilities = capabilities,
      on_attach = on_attach,
      flags = {
        debounce_text_changes = 150,
      }
    }
    if server.name == 'eslint' then
      opts.on_attach = function(client, bufnr)
        -- neovim's LSP client does not currently support dynamic capabilities registration, so we need to set
        -- the resolved capabilities of the eslint server ourselves!
        client.resolved_capabilities.document_formatting = true
        on_attach(client, bufnr)
      end
      opts.settings = {
        format = { enable = true }, -- this will enable formatting
      }
    elseif server.name == 'sumneko_lua' then
      opts.settings = {
        Lua = {
          diagnostics = {
            -- Get the language server to recognize the `vim` global
            globals = {'vim', 'hs'},
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
    end
    server:setup(opts)
  end)


  use 'tami5/lspsaga.nvim'
  require('lspsaga').init_lsp_saga({
    code_action_prompt = {
      -- This was making the "lamp" icon show on the cursor's line all the time
      -- for some projects.
      enable = false,
    }
  })


  use 'nvim-lua/popup.nvim'
  use {
    'nvim-telescope/telescope.nvim',
    requires = {{'nvim-lua/plenary.nvim', 'nvim-telescope/telescope-fzy-native.nvim'}},
  }
  require('telescope').setup({})
  require('telescope').load_extension('fzy_native')

  vim.api.nvim_set_keymap('n', '<LEADER>ff', '<cmd>Telescope find_files<CR>', {silent=false, noremap=true})
  vim.api.nvim_set_keymap('n', '<LEADER>fg', '<cmd>Telescope live_grep<CR>', {silent=false, noremap=true})
  vim.api.nvim_set_keymap('n', '<LEADER>fb', '<cmd>Telescope buffers<CR>', {silent=false, noremap=true})
  vim.api.nvim_set_keymap('n', '<LEADER>fd', '<cmd>Telescope diagnostics<CR>', {silent=false, noremap=true})
  vim.api.nvim_set_keymap('n', '<LEADER>gs', '<cmd>Telescope git_status<CR>', {silent=false, noremap=true})


  use 'TimUntersberger/neogit'
  require('neogit').setup({
    disable_commit_confirmation = true,
    disable_insert_on_commit = false
  })


  use {
    'hoob3rt/lualine.nvim',
    requires = { {'kyazdani42/nvim-web-devicons'} },
  }
  require('lualine').setup({
    options = {
      theme = 'dracula',
      -- theme = 'tokyonight',
    },
    sections = {
      lualine_c = {{'filename', path = 1}}
    },
    inactive_sections = {
      lualine_c = {{'filename', path = 1}},
    }
  })


  use 'thaerkh/vim-workspace'
  vim.g.workspace_autocreate = 1
  vim.g.workspace_session_disable_on_args = 1
  vim.g.workspace_autosave = 0
  -- This plugin functionality makes no sense, it's completely unrelated from its
  -- core functionality :|
  vim.g.workspace_autosave_untrailspaces = 0
  vim.g.workspace_autosave_untrailtabs = 0

  vim.g.workspace_session_directory = vim.fn.expand('~/.local/share/nvim/sessions')
  vim.g.workspace_undodir = vim.fn.expand('~/.local/share/nvim/sessions/.undodir')


  use {
    'vim-test/vim-test',
    requires = {{'voldikss/vim-floaterm'}},
  }
  vim.g['test#strategy'] = 'neovim'
  vim.g['test#neovim#term_position'] = 'botright 20'
  vim.g['test#neovim#start_normal'] = 1

  vim.api.nvim_set_keymap('n', '<LEADER>tn', ':TestNearest<CR><C-w>k', {silent=true, noremap=false})
  vim.api.nvim_set_keymap('n', '<LEADER>tf', ':TestFile<CR><C-w>k', {silent=true, noremap=false})
  vim.api.nvim_set_keymap('n', '<LEADER>ts', ':TestSuite<CR><C-w>k', {silent=true, noremap=false})
  vim.api.nvim_set_keymap('n', '<LEADER>tl', ':TestLast<CR><C-w>k', {silent=true, noremap=false})
  vim.api.nvim_set_keymap('n', '<LEADER>tg', ':TestVisit<CR><C-w>k', {silent=true, noremap=false})


  -- TODO is there a native lua way to do this?
  vim.cmd [[colorscheme dracula]]
  -- vim.cmd [[colorscheme tokyonight]]
  -- vim.cmd [[colorscheme dracula_pro]]

  -- starts terminal mode on insert mode
  -- disables line numbers on a newly opened terminal window (not really working)
  -- autocmd TermOpen term://* startinsert | setlocal nonumber
  -- close terminal buffer without showing the exit status of the shell
  -- autocmd TermClose term://* call feedkeys("\<cr>")
  -- tnoremap <Esc> <C-\><C-n>

  vim.api.nvim_set_keymap('n', '<LEADER>hg', '<cmd>lua require("codehub").openURL("n")<CR>', {noremap=true})
  vim.api.nvim_set_keymap('v', '<LEADER>hg', ':<C-U>lua require("codehub").openURL("v")<CR>', {noremap=true})
  vim.api.nvim_set_keymap('n', '<LEADER>hc', '<cmd>lua require("codehub").copyURL("n")<CR>', {noremap=true})
  vim.api.nvim_set_keymap('v', '<LEADER>hc', ':<C-U>lua require("codehub").copyURL("v")<CR>', {noremap=true})


  use 'mattboehm/vim-accordion'
  -- This makes sure that accordion won't change the height of horizontal
  -- windows/buffers when it calls "wincmd =", and the same for us.
  vim.cmd [[autocmd WinNew * set winfixheight]]
  -- TODO when autocmd is supported on lua we can try to move this to lua properly
  vim.cmd [[autocmd VimEnter,VimResized * execute ":AccordionAll " . string(floor(&columns/(&colorcolumn + 11)))]]


  local function sourceIfExists(file)
    if vim.fn.filereadable(vim.fn.expand(file)) > 0 then
      vim.cmd('source ' .. file)
    end
  end

  sourceIfExists(vim.env.HOME .. '/.fb-vimrc')

end

local packer_bootstrap = nil
local install_path = vim.fn.stdpath('data')..'/site/pack/packer/start/packer.nvim'
if vim.fn.isdirectory(install_path) == 0 then
  packer_bootstrap = vim.fn.system({'git', 'clone', '--depth', '1', 'https://github.com/wbthomason/packer.nvim', install_path})
end

return require('packer').startup({
    function(use)
    if vim.g.vscode == nil then
      onPureNeovim(use)
    end
    onNeovimVSCode(use)

    -- Automatically set up your configuration after cloning packer.nvim
    -- Put this at the end after all plugins
    if packer_bootstrap then
      require('packer').sync()
    end

    vim.cmd [[filetype plugin indent on]]
  end,
  config = {
    display = {
      open_fn = function()
        return require('packer.util').float({ border = 'single' })
      end
    }
  }
})
