local git_ref = '$git_ref'
local modrev = '$modrev'
local specrev = '$specrev'

local repo_url = '$repo_url'

rockspec_format = '3.0'
package = '$package'
if modrev:sub(1, 1) == '$' then
  modrev = "scm"
  specrev = "1"
  repo_url = "https://github.com/neo451/jieba-lua"
  package = repo_url:match("/([^/]+)/?$")
end
-- not jieba-lua
package = 'jieba'
version = modrev .. '-' .. specrev

description = {
  summary = "Chinse word segmentation library.",
  detailed = [[
      Chinse word segmentation library for Lua, based on the original python implementation.
   ]],
  homepage = "https://github.com/neo451/jieba-lua",
  license = "MIT",
}

dependencies = {
   "lua >= 5.1",
   "lpeg >= 1.1.0-1",
   "wordmotion.nvim",
}

test_dependencies = {}

source = {
  url = repo_url .. '/archive/' .. git_ref .. '.zip',
  dir = '$repo_name-' .. '$archive_dir_suffix',
}

if modrev == 'scm' or modrev == 'dev' then
  source = {
    url = repo_url:gsub('https', 'git')
  }
end

build = {
  type = "builtin",
  copy_directories = { 'plugin' },
}
