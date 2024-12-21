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
  { 'AndrewRadev/undoquit.vim' },
  -- { 'jparise/vim-graphql' },
  -- { 'godlygeek/tabular' },
  -- { 'jeffkreeftmeijer/vim-numbertoggle' },

  -- TO BE DEPRECATED ONCE 0.10 is available in all envs I work on
  -- { 'tpope/vim-commentary' },
  -- END DEPRECATED

  { 'williamboman/mason.nvim', config = true },
  {
    'ariel-frischer/bmessages.nvim',
    opts = {
      split_type = 'split',
      split_direction = 'botright',
    },
  },
  {
    'folke/snacks.nvim',
    priority = 1000,
    lazy = false,
    opts = {
      bigfile = { enabled = true },
      input = { enabled = true },
    },
  },
}
