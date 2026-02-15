---simulate (/)/g(/g), support Chinese sentence
-- luacheck: ignore 111 113
local Motion = require "wordmotion".Motion
local utf8 = require("utf8")
local M = {
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

---cut string by punctuations
---@param str string
---@return string[]
function M.Motion:cut(str)
    local sentences = {}
    local last_match
    for match in utf8.gmatch(str, "[^。！？….!?]*[。！？….!?]") do
        last_match = self.insert(sentences, last_match, match)
    end
    local match = utf8.match(str, "[^。！？….!?]+$")
    last_match = self.insert(sentences, last_match, match)
    table.insert(sentences, last_match)
    return sentences
end

---insert last match to matches if current match is capital
---@param matches string[]
---@param last_match string?
---@param match string?
---@return string? last_match
function M.Motion.insert(matches, last_match, match)
    local letter = utf8.sub(match or "", 1, 1)
    -- ignore e.g., etc., ...
    if utf8.upper(letter) ~= letter then
        return (last_match or "") .. match
    end
    last_match = last_match or ""
    table.insert(matches, utf8.match(last_match, "^%s+"))
    table.insert(matches, utf8.match(last_match, "%S.*"))
    return match
end

return M
