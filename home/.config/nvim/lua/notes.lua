local M = {
  default_config = {
    directory = nil,
  },
  config = nil,
}

local function setup_config(config)
  vim.validate({ config = { config, 'table', true } })
  config =
    vim.tbl_deep_extend('force', vim.deepcopy(M.default_config), config or {})
  vim.validate({
    directory = { config.directory, 'string' },
  })
  M.config = config
end

local setup_directory = function()
  local directory = M.config.directory
  if vim.fn.isdirectory(directory) ~= 1 then
    vim.fn.mkdir(directory, 'p')
  end
end

local function define_keymaps()
  -- create new
  vim.keymap.set('n', '<LEADER>nn', function()
    vim.ui.input({ prompt = 'File path: ' }, function(name)
      local path = vim.fs.joinpath(M.config.directory, name)
      vim.cmd('e ' .. path)
    end)
  end)
  -- find files
  vim.keymap.set('n', '<LEADER>nf', function()
    require('telescope.builtin').find_files({
      hidden = true,
      cwd = M.config.directory,
    })
  end)
  -- grep
  vim.keymap.set('n', '<LEADER>ng', function()
    require('telescope.builtin').live_grep({
      cwd = M.config.directory,
    })
  end)
end

return {
  setup = function(config)
    setup_config(config)
    setup_directory()
    define_keymaps()
  end,
}
