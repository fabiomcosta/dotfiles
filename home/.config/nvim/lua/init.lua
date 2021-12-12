
vim.g.mapleader=","

-- turn on syntax highlighting
vim.cmd [[syntax on]]

vim.api.nvim_set_keymap('n', 'j', 'gj', {noremap=true})
vim.api.nvim_set_keymap('n', 'k', 'gk', {noremap=true})

-- moves cursor faster
vim.api.nvim_set_keymap('n', '<DOWN>', '12j', {noremap=true})
vim.api.nvim_set_keymap('v', '<DOWN>', '12j', {noremap=true})
vim.api.nvim_set_keymap('n', '<UP>', '12k', {noremap=true})
vim.api.nvim_set_keymap('v', '<UP>', '12k', {noremap=true})

-- moves the cursor around the buffer windows
vim.api.nvim_set_keymap('n', '<LEFT>', '<C-w>h', {noremap=true})
vim.api.nvim_set_keymap('n', '<RIGHT>', '<C-w>l', {noremap=true})

vim.api.nvim_set_keymap('i', 'jj', '<ESC>', {noremap=true})
vim.api.nvim_set_keymap('n', ';', ':', {noremap=true})
vim.api.nvim_set_keymap('v', ';', ':', {noremap=true})

-- makes ctrl-v work on command-line and search modes
vim.api.nvim_set_keymap('c', '<C-v>', '<C-r>"', {noremap=true})
vim.api.nvim_set_keymap('s', '<C-v>', '<C-r>"', {noremap=true})

vim.api.nvim_set_keymap('n', '<LEADER>ev', ':e $MYVIMRC<CR>', {noremap=true})
vim.api.nvim_set_keymap('n', '<LEADER>v', ':vsplit<CR><C-w>l', {noremap=true})

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
  -- use 'godlygeek/tabular'
  -- use 'jeffkreeftmeijer/vim-numbertoggle'
  -- use 'w0rp/ale'


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


  use 'ntpeters/vim-better-whitespace'
  vim.api.nvim_set_keymap('n', '<LEADER>W', ':StripWhitespace<CR>', { silent=true, noremap=true })
end


local function onPureNeovim(use)

  use 'sheerun/vim-polyglot'
  vim.g.javascript_plugin_flow = 1


  use 'othree/eregex.vim'
  vim.g.eregex_default_enable = 0


  use 'haya14busa/incsearch.vim'
  vim.o.hlsearch = true
  vim.g['incsearch#auto_nohlsearch'] = 1
  vim.api.nvim_set_keymap('', '/', '<Plug>(incsearch-forward)', { noremap=false })
  vim.api.nvim_set_keymap('', 'n', '<Plug>(incsearch-nohl-n)', { noremap=false })
  vim.api.nvim_set_keymap('', 'N', '<Plug>(incsearch-nohl-N)', { noremap=false })
  vim.api.nvim_set_keymap('', '*', '<Plug>(incsearch-nohl-*)', { noremap=false })
  vim.api.nvim_set_keymap('', '#', '<Plug>(incsearch-nohl-#)', { noremap=false })
  vim.api.nvim_set_keymap('', 'g*', '<Plug>(incsearch-nohl-g*)', { noremap=false })
  vim.api.nvim_set_keymap('', 'g#', '<Plug>(incsearch-nohl-g#)', { noremap=false })
  vim.api.nvim_set_keymap('', '<LEADER>/', '<Plug>(incsearch-forward)<C-r><C-w><CR>', { noremap=false })


  use 'rhysd/git-messenger.vim'
  vim.g.git_messenger_floating_win_opts = { border='single' }
  vim.g.git_messenger_popup_content_margins = false
  vim.api.nvim_set_keymap('n', '<LEADER>gm', ':GitMessenger<CR>', { silent=true, noremap=false })


  use {'dracula/vim', as='dracula'}
  -- use '~/gdrive/code/dracula-pro/themes/vim'
  -- vim.g.dracula_colorterm = 0


  use 'tpope/vim-vinegar'
  vim.g.netrw_liststyle = 3
  vim.api.nvim_set_keymap('n', '<LEADER>z', ':Vexplore<CR>', { silent=true, noremap=true })


  use 'mattboehm/vim-accordion'
  -- TODO when autocmd is supported on lua we can try to move this to lua properly
  vim.api.nvim_exec(
  [[
  fun! s:AutoSetAccordionValue()
    execute ":AccordionAll " . string(floor(&columns/101))
  endfun

  autocmd VimEnter,VimResized * call s:AutoSetAccordionValue()
  ]], false)


  -- function! CocAfterUpdate(info)
  --   CocInstall coc-eslint
  --   CocInstall coc-prettier
  -- endfunction
  use {'neoclide/coc.nvim', branch='release'}


  use 'cohama/lexima.vim'


  use 'kwkarlwang/bufjump.nvim'
  require('bufjump').setup()

  vim.api.nvim_set_keymap('n', '<C-p>', ':lua require("bufjump").backward()<CR>', {silent=true, noremap=true})
  vim.api.nvim_set_keymap('n', '<C-n>', ':lua require("bufjump").forward()<CR>', {silent=true, noremap=true})


  use {'nvim-treesitter/nvim-treesitter', run=':TSUpdate'}
  use 'windwp/nvim-ts-autotag'
  require('nvim-treesitter.configs').setup({
    ensure_installed = { 'javascript', 'typescript', 'tsx', 'lua', 'html', 'fish', 'json', 'yaml', 'scss', 'css', 'python', 'bash', 'erlang', 'graphql', 'vim' },
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
    }
  })
  local parser_config = require 'nvim-treesitter.parsers'.get_parser_configs()
  parser_config.tsx.used_by = 'javascript'


  use 'hrsh7th/cmp-nvim-lsp'
  use 'hrsh7th/cmp-buffer'
  use 'hrsh7th/cmp-path'
  use 'hrsh7th/cmp-cmdline'
  use 'hrsh7th/nvim-cmp'

  vim.o.completeopt = 'menu,menuone,noselect'

  local cmp = require'cmp'
  cmp.setup({
    mapping = {
      ['<C-b>'] = cmp.mapping(cmp.mapping.scroll_docs(-4), { 'i', 'c' }),
      ['<C-f>'] = cmp.mapping(cmp.mapping.scroll_docs(4), { 'i', 'c' }),
      ['<C-Space>'] = cmp.mapping(cmp.mapping.complete(), { 'i', 'c' }),
      ['<C-y>'] = cmp.config.disable, -- Specify `cmp.config.disable` if you want to remove the default `<C-y>` mapping.
      ['<C-e>'] = cmp.mapping({
        i = cmp.mapping.abort(),
        c = cmp.mapping.close(),
      }),
      -- Accept currently selected item. If none selected, `select` first item.
      -- Set `select` to `false` to only confirm explicitly selected items.
      ['<CR>'] = cmp.mapping.confirm({ select = true }),
    },
    sources = cmp.config.sources({
      { name = 'nvim_lsp' },
    }, {
      { name = 'buffer' },
    })
  })
  -- Use buffer source for `/` (if you enabled `native_menu`, this won't work anymore).
  cmp.setup.cmdline('/', {
    sources = {
      { name = 'buffer' }
    }
  })
  -- Use cmdline & path source for ':' (if you enabled `native_menu`, this won't work anymore).
  -- cmp.setup.cmdline(':', {
  --   sources = cmp.config.sources({
  --     { name = 'path' }
  --   }, {
  --     { name = 'cmdline' }
  --   })
  -- })


  local signs = { Error = "●", Warning = "●", Hint = "●", Information = "●" }
  for type, icon in pairs(signs) do
    local hl = "LspDiagnosticsSign" .. type
    vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = "" })
  end


  use 'neovim/nvim-lspconfig'
  use 'williamboman/nvim-lsp-installer'
  use 'JoosepAlviste/nvim-ts-context-commentstring'


  local nvim_lsp = require('lspconfig')

  -- Use an on_attach function to only map the following keys
  -- after the language server attaches to the current buffer
  local on_attach = function(client, bufnr)
    local function buf_set_keymap(...) vim.api.nvim_buf_set_keymap(bufnr, ...) end

    -- Mappings.
    local opts = { noremap=true, silent=true }

    -- See `:help vim.lsp.*` for documentation on any of the below functions

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

    buf_set_keymap('n', '<LEADER>lg', '<cmd>lua require("lspsaga.floaterm").open_float_terminal("lazygit")<CR>', opts)

  end

  local capabilities = require('cmp_nvim_lsp')
    .update_capabilities(vim.lsp.protocol.make_client_capabilities())

  -- Use a loop to conveniently call 'setup' on multiple servers and
  -- map buffer local keybindings when the language server attaches
  local servers = { 'flow' }
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
    if server.name == 'sumneko_lua' then
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
  use 'nvim-lua/plenary.nvim'
  use 'nvim-telescope/telescope.nvim'
  vim.api.nvim_set_keymap('n', '<LEADER>ff', '<cmd>Telescope find_files<CR>', { silent=false, noremap=true })
  vim.api.nvim_set_keymap('n', '<LEADER>fg', '<cmd>Telescope live_grep<CR>', { silent=false, noremap=true })
  vim.api.nvim_set_keymap('n', '<LEADER>fb', '<cmd>Telescope buffers<CR>', { silent=false, noremap=true })
  vim.api.nvim_set_keymap('n', '<LEADER>fr', '<cmd>Telescope lsp_references<CR>', { silent=false, noremap=true })
  vim.api.nvim_set_keymap('n', '<LEADER>fd', '<cmd>Telescope lsp_workspace_diagnostics<CR>', { silent=false, noremap=true })
  vim.api.nvim_set_keymap('n', '<LEADER>gs', '<cmd>Telescope git_status<CR>', { silent=false, noremap=true })
  vim.api.nvim_set_keymap('n', '<LEADER>gb', '<cmd>Telescope git_branches<CR>', { silent=false, noremap=true })


  use 'TimUntersberger/neogit'
  require('neogit').setup({
    disable_commit_confirmation = true,
    disable_insert_on_commit = false
  })


  use 'kyazdani42/nvim-web-devicons'
  use 'hoob3rt/lualine.nvim'
  require('lualine').setup({
    options = { theme = 'dracula' }
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


  use 'voldikss/vim-floaterm'
  use 'vim-test/vim-test'
  vim.g['test#strategy'] = 'floaterm'
  vim.g['test#neovim#start_normal'] = 1
  vim.g['test#basic#start_normal'] = 1

  vim.api.nvim_set_keymap('n', '<LEADER>tn', ':TestNearest<CR>', { silent=true, noremap=false })
  vim.api.nvim_set_keymap('n', '<LEADER>tf', ':TestFile<CR>', { silent=true, noremap=false })
  vim.api.nvim_set_keymap('n', '<LEADER>ts', ':TestSuite<CR>', { silent=true, noremap=false })
  vim.api.nvim_set_keymap('n', '<LEADER>tl', ':TestLast<CR>', { silent=true, noremap=false })
  vim.api.nvim_set_keymap('n', '<LEADER>tg', ':TestVisit<CR>', { silent=true, noremap=false })


  -- TODO is there a native lua way to do this?
  vim.cmd [[colorscheme dracula]]
  -- vim.cmd [[colorscheme dracula_pro]]

  -- starts terminal mode on insert mode
  -- disables line numbers on a newly opened terminal window (not really working)
  -- autocmd TermOpen term://* startinsert | setlocal nonumber
  -- close terminal buffer without showing the exit status of the shell
  -- autocmd TermClose term://* call feedkeys("\<cr>")
  -- tnoremap <Esc> <C-\><C-n>

end


local packer_bootstrap = nil
local install_path = vim.fn.stdpath('data')..'/site/pack/packer/start/packer.nvim'
if not vim.fn.isdirectory(install_path) then
  packer_bootstrap = vim.fn.system({'git', 'clone', '--depth', '1', 'https://github.com/wbthomason/packer.nvim', install_path})
end

return require('packer').startup(function(use)
  if vim.g.vscode == nil then
    onPureNeovim(use)
  else
    onNeovimVSCode(use)
  end
  -- Automatically set up your configuration after cloning packer.nvim
  -- Put this at the end after all plugins
  if packer_bootstrap then
    require('packer').sync()
  end
end)
