local utils = require('utils')

return {
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
  { 'tpope/vim-commentary' },
  -- END DEPRECATED

  { 'j-hui/fidget.nvim',              config = true },
  { 'folke/neodev.nvim',              config = true },
  {
    'williamboman/mason.nvim',
    enabled = not utils.is_meta_server(),
    config = true,
    build = function()
      local packages = {
        'prettier',
        'stylua',
        'eslint-lsp',
        'typescript-language-server',
        'lua-language-server',
        'rust-analyzer',
      }
      vim.cmd(':MasonInstall ' .. vim.fn.join(packages, ' '))
    end,
  },
}
