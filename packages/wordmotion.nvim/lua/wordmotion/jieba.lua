---simulate b/e/w/ge, support Chinese token
-- luacheck: ignore 111 113
local Motion = require "wordmotion.sentence".Motion
local M = {
    backends = {
        "cppjieba.jieba",
        "rjieba.jieba",
        "jieba.jieba",
    },
    Motion = {
    }
}

---@param motion table?
---@return table motion
function M.Motion:new(motion)
    motion = motion or {}
    if motion.jieba == nil then
        for _, backend in ipairs(M.backends) do
            local ok, mod = pcall(require, backend)
            if ok then
                motion.jieba = mod.Jieba()
                break
            end
        end
    end
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

---cut string to get **non-empty** words: `utf8.offset("", -1) == nil`
---@param str string
---@return string[]
function M.Motion:cut(str)
    return self.jieba:cut(str)
end

return M
