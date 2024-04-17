package = "jieba"
version = "1.0.0-1"
source = {
   url = "git+https://github.com/noearc/jieba-lua.git",
   tag = "v1.0.0",
}
description = {
   summary = "Chinse word segmentation library.",
   detailed = [[
      Chinse word segmentation library for Lua, based on the original python implementation.
   ]],
   homepage = "https://github.com/noearc/jieba-lua",
   license = "MIT",
}
dependencies = {
   "lua >= 5.1",
   "lpeg >= 1.1.0-1",
}
build = {
   copy_directories = { "dict" },
   type = "builtin",
   modules = {
      ["jieba.init"] = "lua/jieba/init.lua",
      ["jieba.utils"] = "lua/jieba/utils.lua",
      ["jieba.utf8"] = "lua/jieba/utf8.lua",
      ["jieba.hmm"] = "lua/jieba/hmm.lua",
      ["jieba.prob_emit"] = "lua/jieba/prob_emit.lua",
      ["jieba.prob_start"] = "lua/jieba/prob_start.lua",
      ["jieba.prob_trans"] = "lua/jieba/prob_trans.lua",
   },
}
