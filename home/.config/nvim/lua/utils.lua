local function identity(a1)
  return a1
end

-- See https://www.lua.org/pil/17.1.html
local function memoize(fn, cache_key_gen)
  cache_key_gen = cache_key_gen or identity
  local cache = {}
  setmetatable(cache, { __mode = 'kv' })
  return function(...)
    local args = { ... }
    local cache_key = cache_key_gen(unpack(args))
    if #args == 0 and cache_key == nil then
      cache_key = vim.NIL
    elseif type(cache_key) ~= 'string' then
      return error('Cache key needs to be a string.')
    end
    if cache[cache_key] == vim.NIL then
      return nil
    end
    if cache[cache_key] ~= nil then
      return cache[cache_key]
    end
    local result = fn(unpack(args))
    cache[cache_key] = result == nil and vim.NIL or result
    return result
  end
end

local utils = {
  memoize = memoize,
}

local function create_make_repeatable()
  local n = 0
  _G.__rptcbs = {}
  return function(callback)
    n = n + 1
    local callback_name = 'cb' .. tostring(n)
    _G.__rptcbs[callback_name] = function()
      callback()
    end
    return function()
      vim.go.operatorfunc = 'v:lua.__rptcbs.' .. callback_name
      return 'g@l'
    end
  end
end
local make_repeatable = create_make_repeatable()

-- Creates mappings that are dot repeatable, meaning when pressing the "."
-- key it execute again.
-- Note that the callback can't run functions like vim.cmd.normal and can't
-- return expressions.
function utils.keymap_set_repeatable(modes, map, callback, opts)
  opts = vim.tbl_deep_extend('force', opts or {}, {
    expr = true,
  })
  vim.keymap.set(modes, map, make_repeatable(callback), opts)
end

function utils.module_exists(module_name)
  return pcall(require, module_name)
end

function utils.require_if_exists(module_name, callback)
  local exists, module = pcall(require, module_name)
  if exists then
    callback(module)
  end
end

function utils.tbl_contains(tbl, element)
  for _, value in pairs(tbl) do
    if value == element then
      return true
    end
  end
  return false
end

function utils.joinpath(...)
  local args = { ... }
  if vim.fs.joinpath ~= nil then
    return vim.fs.joinpath(unpack(args))
  end
  return vim.fn.join(args, '/')
end

function utils.set_keymap(mode, lhs, rhs, opts)
  opts = vim.tbl_deep_extend('keep', opts or {}, {
    silent = true,
    noremap = true,
  })
  vim.api.nvim_set_keymap(mode, lhs, rhs, opts)
end

local lsp_augroup = vim.api.nvim_create_augroup('LspFormatting', {})
function utils.auto_format_on_save(client, bufnr)
  -- if client.server_capabilities.document_formatting then
  if client.supports_method('textDocument/formatting') then
    vim.api.nvim_clear_autocmds({ group = lsp_augroup, buffer = bufnr })
    vim.api.nvim_create_autocmd('BufWritePre', {
      group = lsp_augroup,
      buffer = bufnr,
      callback = function()
        vim.lsp.buf.format({ timeout_ms = 2000 })
      end,
    })
  end
end

return utils
