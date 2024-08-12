return {
  {
    "ThePrimeagen/refactoring.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-treesitter/nvim-treesitter",
    },
    config = function()
      require("refactoring").setup({
        print_var_statements = {
          hack = {"slog('%s', %s);"},
          php = {"print_r('%s', %s);"}
        }
      })
      vim.keymap.set(
        {"x", "n"},
        "<LEADER>rv",
        function() require('refactoring').debug.print_var() end
      )
      vim.keymap.set(
        "n",
        "<LEADER>rc",
        function() require('refactoring').debug.cleanup({}) end
      )
    end,
  }
}
