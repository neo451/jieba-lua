---wrap `require'jieba'.Jieba`
local cut = require 'jieba.core'.cut
local M = {
    Jieba = {
        --- if hmm is enabled
        hmm = true,
    }
}

---@param jieba table?
---@return table? jieba
function M.Jieba:new(jieba)
    jieba = jieba or {}
    setmetatable(jieba, {
        __index = self
    })

    return jieba
end

setmetatable(M.Jieba, {
    __call = M.Jieba.new
})

---cut string
---@param str string
---@param hmm boolean?
---@return string[]
function M.Jieba:cut(str, hmm)
    if hmm == nil then
        hmm = self.hmm
    end
    local tokens = cut(str, false, hmm)
    return tokens
end

return M
