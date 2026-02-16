---simulate vim's word motion
---@module wordmotion
-- luacheck: ignore 111 113 212
local utf8 = require("utf8")
local M = {
    Motion = {
        keep = false,
    }
}

---get end index
---@param str string
---@return integer
function M.end_index(str)
    return (utf8.offset(str, -1) or 1) - 1
end

---@param motion table?
---@return table? motion
function M.Motion:new(motion)
    motion = motion or {}
    setmetatable(motion, {
        __index = self
    })
    return motion
end

setmetatable(M.Motion, {
    __call = M.Motion.new
})

---factory method
---@param txt string
---@return table
function M.Motion:from_path(txt)
    local f = io.open(txt)
    local motion = self()
    if f then
        motion.lines = {}
        for line in f:lines() do
            table.insert(motion.lines, line)
        end
        f:close()
    end
    return motion
end

---cut string. abstract method
---@param str string
---@return {text: string, illegal: boolean?, start_index: integer, end_index: integer}[]
function M.Motion:get_tokens(str)
    return { { text = str, start_index = 0, end_index = M.end_index(str) } }
end

---get line
---@param l integer
---@return string line
function M.Motion:get_line(l)
    return self.lines and self.lines[l] or vim.api.nvim_buf_get_lines(0, l - 1, l, true)[1]
end

---get lines
---@return string[]
function M.Motion:get_lines()
    return self.lines or vim.api.nvim_buf_get_lines(0, 0, -1, true)
end

---get next/previous character's position
---@param forward boolean
---@param cursor integer[]
---@return integer[] cursor
function M.Motion:get_character(forward, cursor)
    local l = cursor[1]
    local c = cursor[2]
    local line = self:get_line(l)
    -- lua string index from 1
    c = utf8.next(line, c + 1, forward and 1 or -1)
    if c then
        return { l, c - 1 }
    end
    if not forward then
        l = l - 1
        if l < 1 then
            return { 1, 0 }
        end
        line = self:get_line(l)
        return { l, M.end_index(line) }
    end
    l = l + 1
    local l_end = #self:get_lines()
    if l > l_end then
        line = self:get_line(l_end)
        return { l_end, M.end_index(line) }
    end
    return { l, 0 }
end

---get cursor position
---@param count integer
---@param begin boolean jump to token's begin: b/w
---@param cursor integer[]
---@return integer[] cursor
function M.Motion:get_cursor(count, begin, cursor)
    local l = cursor[1]
    local c = cursor[2]
    local line = self:get_line(l)
    local tokens = self:get_tokens(line)
    local index = 0
    for i, token in ipairs(tokens) do
        if token.end_index >= c then
            index = i
            break
        end
    end
    if index > 0 then
        local token = tokens[index]
        local _c = begin and token.start_index or token.end_index
        if not token.illegal then
            if count > 0 then
                token.illegal = _c < c
            else
                token.illegal = _c > c
            end
        end
        while token do
            if not token.illegal then
                count = count + (count > 0 and -1 or 1)
                if count == 0 then
                    c = begin and token.start_index or token.end_index
                    return { l, c }
                end
            end
            index = index + (count < 0 and -1 or 1)
            token = tokens[index]
        end
    end
    l = l + (count > 0 and 1 or -1)
    local l_end = #self:get_lines()
    if l < 1 or l > l_end then
        return {}
    end
    line = self:get_line(l)
    c = count > 0 and 0 or M.end_index(line)
    return self:get_cursor(count, begin, { l, c })
end

---get position
---@param count integer
---@param begin boolean jump to token's begin: b/w
---@param cursor integer[]
---@return integer[] cursor
function M.Motion:get_position(count, begin, cursor)
    local pos = cursor
    if not self.keep then
        pos = self:get_character(count > 0, cursor)
    end
    pos = self:get_cursor(count, begin, pos)
    if #pos == 0 then
        pos = cursor
    end
    return pos
end

---displace cursor
---@param begin boolean jump to token's begin: b/w
---@param count integer?
function M.Motion:displace(begin, count)
    count = count or vim.v.count1
    local cursor = vim.api.nvim_win_get_cursor(0)
    local pos = self:get_position(count, begin, cursor)
    vim.api.nvim_win_set_cursor(0, pos)
end

---move by text object
---@param begin boolean jump to token's begin: b/w
---@param forward boolean
function M.Motion:move(begin, forward)
    self:displace(begin, vim.v.count1 * (forward and 1 or -1))
end

---select text object
---@param around boolean iw/aw
function M.Motion:select(around)
    self:displace(true, -1)
    vim.cmd[[normal! o]]
    self:displace(around, vim.v.count1)
end

---select or move
---@param around boolean iw/aw
---@param forward boolean?
function M.Motion:keymap(around, forward)
    if forward == nil then
        self:select(around)
    else
        self:move(around, forward)
    end
end

return M
