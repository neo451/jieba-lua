---simulate (/)/g(/g), support Chinese sentence
-- luacheck: ignore 111 113
local Motion = require "wordmotion".Motion
local utf8 = require("utf8")
local M = {
    punctuations = {
        en = { ".", "!", "?" },
        zh = { "。", "！", "?" },
    },
    Motion = {
    }
}

---@param motion table?
---@return table motion
function M.Motion:new(motion)
    motion = motion or {}
    motion = Motion(motion)
    setmetatable(motion, {
        __index = self
    })
    return motion
end

setmetatable(M.Motion, {
    __index = Motion,
    __call = M.Motion.new
})

---cut string to get sentences
---@param str string
---@return {text: string, illegal: boolean?, start_index: integer, end_index: integer}[]
function M.Motion:get_tokens(str)
    local tokens = {}
    local c = 0
    for _, text in ipairs(self:cut(str)) do
        table.insert(tokens,
            {
                text = text,
                illegal = utf8.match(text, "%s*") == text,
                start_index = c,
                end_index = c + utf8.offset(text, -1) - 1
            })
        c = c + #text
    end
    return tokens
end

---TODO:
---cut string by punctuations
---@param str string
---@return string[]
function M.Motion:cut(str)
    return {}
end

return M
