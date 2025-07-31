local utils = require('utils')
local set_keymap = utils.set_keymap
local is_meta_server = utils.is_meta_server

-- fonts and other gui stuff
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
-- uses OS clipboard if possible (check +clipboard)
vim.opt.clipboard:append({ 'unnamed', 'unnamedplus' })
-- store lots of :cmdline history
vim.opt.history = 1000
-- mark the ideal max text width
vim.opt.colorcolumn = '80'
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

vim.opt.conceallevel = 2
vim.opt.concealcursor = 'nc'

set_keymap('n', 'j', 'gj')
set_keymap('n', 'k', 'gk')

-- moves cursor faster
set_keymap('n', '<DOWN>', '12j')
set_keymap('v', '<DOWN>', '12j')
set_keymap('n', '<UP>', '12k')
set_keymap('v', '<UP>', '12k')

set_keymap('i', 'jj', '<ESC>')
set_keymap('n', ';', ':', { silent = false })
set_keymap('v', ';', ':', { silent = false })

-- makes ctrl-v work on command-line and search modes
set_keymap('c', '<C-v>', '<C-r>"')
set_keymap('s', '<C-v>', '<C-r>"')

local initLuaFilePath = debug.getinfo(1).source:sub(2)
set_keymap('n', '<LEADER>ev', ':e ' .. initLuaFilePath .. '<CR>')
set_keymap('n', '<LEADER>\\', ':vsplit<CR><C-w>l')
set_keymap('n', '<LEADER>-', ':split<CR><C-w>j')

-- changes the size of the buffer windows
set_keymap('n', '=', '<C-w>=')
set_keymap('n', '<RIGHT>', ':vertical resize +5<CR>')
set_keymap('n', '<LEFT>', ':vertical resize -5<CR>')
set_keymap('n', '+', ':resize +5<CR>')
set_keymap('n', '-', ':resize -5<CR>')

-- tab related mappings
set_keymap('n', '<LEADER>tc', ':tabnew<CR>')
set_keymap('n', '<LEADER>tp', ':tabprevious<CR>')
set_keymap('n', '<LEADER>tn', ':tabnext<CR>')

-- avoid going on ex mode
set_keymap('n', 'Q', '<NOP>')

-- Keeps selection when changing indentation
-- https://github.com/mhinz/vim-galore#dont-lose-selection-when-shifting-sidewards
set_keymap('x', '<', '<gv')
set_keymap('x', '>', '>gv')

-- Disable cursorline highlight on insert mode
-- https://github.com/mhinz/vim-galore#smarter-cursorline
vim.cmd([[autocmd InsertLeave,WinEnter * set cursorline]])
vim.cmd([[autocmd InsertEnter,WinLeave * set nocursorline]])

-- copies current buffer file path relative to cwd to register
vim.keymap.set('n', 'cp', function()
  local path = vim.fn.resolve(vim.fn.fnamemodify(vim.fn.expand('%'), ':~:.'))
  vim.fn.setreg('+', path)
end)

-- copies current buffer filename to register
vim.keymap.set('n', 'cf', function()
  local filename =
      vim.fn.resolve(vim.fn.fnamemodify(vim.fn.expand('%:r'), ':t'))
  vim.fn.setreg('+', filename)
end)

vim.filetype.add({
  extension = {
    php = function(_path, bufnr)
      local getline = vim.filetype.getline or vim.filetype._getline
      if vim.startswith(getline(bufnr, 1), '<?hh') then
        return 'hack',
            function(_bufnr)
              vim.opt_local.syntax = 'php'
              vim.opt_local.iskeyword:append('$')
            end
      end
      return 'php'
    end,
    -- js = function(_path, bufnr)
    --   local getlines = vim.filetype.getlines or vim.filetype._getlines;
    --   for _, line in ipairs(getlines(bufnr, 1, 16)) do
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

vim.api.nvim_create_user_command('SetupAndQuit', function()
  if not is_meta_server() then
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
  -- this makes lazy lines and sync meta ls stuff run on their own lines
  print('')
  require('lazy').sync()
end, {})

set_keymap('n', '<LEADER>W', ':StripWhitespace<CR>')

vim.keymap.set('n', '<LEADER>hg', function()
  require('codehub').openURL('n')
end)
vim.keymap.set('v', '<LEADER>hg', function()
  require('codehub').openURL('v')
end)
vim.keymap.set('n', '<LEADER>hc', function()
  require('codehub').copyURL('n')
end)
vim.keymap.set('v', '<LEADER>hc', function()
  require('codehub').copyURL('v')
end)

vim.api.nvim_create_user_command('MetaDiffCheckout', function()
  require('meta_diff').diff_picker({ checkout = true })
end, {})
vim.api.nvim_create_user_command('MetaDiffOpenFiles', function()
  require('meta_diff').diff_picker({})
end, {})

set_keymap('n', '<LEADER>mc', '<CMD>MetaDiffCheckout<CR>')
set_keymap('n', '<LEADER>mf', '<CMD>MetaDiffOpenFiles<CR>')

-- starts terminal mode on insert mode
-- disables line numbers on a newly opened terminal window (not really working)
vim.cmd([[autocmd TermOpen term://* setlocal nonumber]])
-- close terminal buffer without showing the exit status of the shell
-- autocmd TermClose term://* call feedkeys("\<cr>")
-- tnoremap <Esc> <C-\><C-n>

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

-- open modified [files]
set_keymap('n', '<LEADER>om', '<CMD>GitOpenActiveFiles<CR>')

require('keyword_case').setup()

set_keymap('n', '<LEADER>cc', '<CMD>CodeCycleCase<CR>')

vim.opt.sessionoptions:remove('blank')
vim.opt.sessionoptions:remove('buffers')
require('micro_sessions').setup({
  directory = utils.joinpath(vim.fn.stdpath('data'), 'sessions'),
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

require('lazy').setup({
  { import = 'plugins' },
}, { dev = { path = '~/Dev/nvim-plugins' } })
