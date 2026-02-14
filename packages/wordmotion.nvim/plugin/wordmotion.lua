---plugin. load dictionary is slow
---@diagnostic disable: undefined-global
-- luacheck: ignore 112 113
vim.schedule(
    function()
        require 'wordmotion.nvim.jieba'.init()
    end
)
require 'wordmotion.nvim.jieba'.set_keymaps()
-- require 'wordmotion.nvim.sentence'.set_keymaps()
