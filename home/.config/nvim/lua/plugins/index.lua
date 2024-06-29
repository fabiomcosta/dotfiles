local utils = require('utils')

return {
  { 'jordwalke/VimAutoMakeDirectory' },
  { 'tpope/vim-git' },
  { 'tpope/vim-surround' },
  { 'tpope/vim-repeat' },
  { 'tpope/vim-fugitive' },
  { 'moll/vim-node' },
  { 'christoomey/vim-tmux-navigator' },
  { 'ntpeters/vim-better-whitespace' },
  { 'andymass/vim-matchup' },
  { 'wellle/targets.vim' },
  -- { 'jparise/vim-graphql' },
  -- { 'godlygeek/tabular' },
  -- { 'jeffkreeftmeijer/vim-numbertoggle' },

  -- TO BE DEPRECATED ONCE 0.10 is available in all envs I work on
  { 'tpope/vim-commentary' },
  -- END DEPRECATED

  { 'j-hui/fidget.nvim', config = true },
  { 'folke/neodev.nvim', config = true },
  { 'williamboman/mason.nvim', config = true },
}
