local distant_cli = require('distant.cli')
local connection = require('meta-local.connection')

require('telescope').load_extension('distant_find_files')
require('telescope').load_extension('distant_biggrep')

vim.api.nvim_create_user_command('MetaSelectConnection', function()
  distant_cli.install({}, function(err, path)
    if err then
      vim.api.nvim_err_writeln(err)
      return
    end
    vim.notify('Distant is installed on ' .. path)
    connection.select_connection()
  end)
end, {})

vim.api.nvim_create_user_command('MetaConnectToNewServer', function()
end, {})

vim.api.nvim_create_user_command('MetaSelectCwd', function()
  connection.select_cwd()
end, {})

return {
  status = require('meta-local.status').get,
}

-- just while developing
-- connection.select_cwd()
-- connection.select_connection()
