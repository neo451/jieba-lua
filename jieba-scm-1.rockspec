rockspec_format = '3.0'
description = {
  summary = '',
  detailed = '',
  labels = {},
  homepage = "https://github.com/neo451/jieba-lua",
  license = "MIT",
}
-- not jieba-lua
package = 'jieba'
version = 'scm-1'
source = {
  url = description.homepage:gsub('https', 'git')
}
build = {
  type = 'builtin',
  copy_directories = { 'plugin' },
}

dependencies = {
  "lua >= 5.1",
  "lpeg >= 1.1.0-1",
  "wordmotion.nvim",
}
