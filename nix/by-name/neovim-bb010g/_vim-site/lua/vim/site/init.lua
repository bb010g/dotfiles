-- SPDX-License-Identifier: Apache-2.0 OR ISC
-- SPDX-FileCopyrightText: Dusk Banks <me@bb010g.com>

-- SPDX-SnippetBegin
-- SPDX-License-Identifier: 0BSD
-- SPDX-SnippetCopyrightText: Dusk Banks <me@bb010g.com>
-- For the very start of your vimrc:
--[[
do local vimSubmodules = vim._submodules; if vimSubmodules.site == nil then vimSubmodules.site = true end end
--]]
-- SPDX-SnippetEnd

local vim_site_module, vim_site_submodule
local vim_site_is_submodule = vim._submodules.site, false
if vim_site_is_submodule then
  -- prevent require loops
  pcall(function() vim_site_submodule = vim.site; vim_site_module = vim_site_submodule end)
end
if vim_site_module == nil then vim_site_module = {} end
-- These are for loading runtime modules in the vim.site namespace lazily.
if vim_site_module._submodules == nil then vim_site_module._submodules = {} end
if vim_site_module._submodule_loading == nil then vim_site_module._submodule_loading = {} end
local vim_site_module_mt = getmetatable(vim_site_module)
if vim_site_module_mt == nil then vim_site_module_mt = {} end
--- @param t table<any,any>
function vim_site_module_mt.__index(t, key)
  local vim_site = vim.site
  if vim_site == nil then vim_site = vim_site_module end
  if vim_site._submodules[key] then
    vim_site._submodule_loading[key] = true
    t[key] = require('vim.site.' .. key)
    vim_site._submodule_loading[key] = false
    return t[key]
  end
end
setmetatable(vim_site_module, vim_site_module_mt)

-- site functions which always should be available
local overriding_vim_site_submodule = vim_site_is_submodule and vim_site_submodule == nil
if overriding_vim_site_submodule then vim.site = vim_site_module end
local ok, vim_site_shared = pcall(require, 'vim.site.shared')
if overriding_vim_site_submodule then vim.site = vim_site_submodule end

return vim_site_module
