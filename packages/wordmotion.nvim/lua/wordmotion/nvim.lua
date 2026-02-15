---set keymaps
---@diagnostic disable: undefined-global
-- luacheck: ignore 112 113
local M = {}

---set keymaps
---@param keymaps {string: {[1]: string[], [2]: boolean[]}}}
---@param callback function
function M.set_keymaps(keymaps, callback)
    for lhs, keymap in pairs(keymaps) do
        local modes = keymap[1]
        local args = keymap[2]
        vim.keymap.set(modes, lhs, callback(args), { noremap = true })
    end
end

return M
