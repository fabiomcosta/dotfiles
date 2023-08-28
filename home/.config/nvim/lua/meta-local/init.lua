local distant = require('distant')
local connection = require('meta-local.connection')
local telescope = require('telescope')

telescope.load_extension('distant_find_files')
telescope.load_extension('distant_biggrep')

vim.api.nvim_create_user_command('MetaSelectConnection', function()
  distant:cli():install({}, function(err, path)
    if err then
      vim.api.nvim_err_writeln(err)
      return
    end
    vim.notify('Distant is installed on ' .. path)
    connection.select_connection()
  end)
end, {})

vim.api.nvim_create_user_command('MetaConnectToNewServer', function() end, {})

vim.api.nvim_create_user_command('MetaSelectCwd', function()
  connection.select_cwd()
end, {})

connection.select_connection()
-- just while developing
-- connection.select_cwd()

return {
  status = require('meta-local.status').get,
}
