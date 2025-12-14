return {
  { 'jordwalke/VimAutoMakeDirectory' },
  { 'tpope/vim-git' },
  { 'tpope/vim-surround' },
  { 'tpope/vim-repeat' },
  { 'tpope/vim-fugitive' },
  { 'moll/vim-node' },
  { 'ntpeters/vim-better-whitespace' },
  { 'andymass/vim-matchup' },
  { 'wellle/targets.vim' },
  { 'AndrewRadev/undoquit.vim' },
  -- { 'jparise/vim-graphql' },
  -- { 'godlygeek/tabular' },
  -- { 'jeffkreeftmeijer/vim-numbertoggle' },
  {
    'OliverChao/bufmsg.nvim',
    opts = {
      split_type = 'split',
      -- split_direction = 'botright',
      -- keep_focus = true,
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
