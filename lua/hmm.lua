local M = {}
local MIN_FLOAT = -3.14e100
local start = require("prob_start")
local emit = require("prob_emit")
local trans = require("prob_trans")
local ut = require("jb_utils")

-- add forcesplit

local PrevStatus = {
	["B"] = { "E", "S" },
	["M"] = { "M", "B" },
	["S"] = { "S", "E" },
	["E"] = { "B", "M" },
}

local function viterbi(obs, states, start_p, trans_p, emit_p)
    local V = { {} } -- tabular
    local prev_best_state = {} -- optimized space usage
    
    for _, y in pairs(states) do -- init
        V[1][y] = start_p[y] + (emit_p[y][obs[1]] or MIN_FLOAT)
        prev_best_state[y] = {}
    end
    
    for t = 2, #obs do
        V[t] = {}
        for _, y in pairs(states) do
            local em_p = (emit_p[y][obs[t]] or MIN_FLOAT)
            local max_prob = MIN_FLOAT
            local best_prev_state
            
            for _, y0 in pairs(states) do
                local tr_p = trans_p[y0][y] or MIN_FLOAT
                local prob0 = V[t - 1][y0] + tr_p + em_p
                if prob0 > max_prob then
                    max_prob = prob0
                    best_prev_state = y0
                end
            end
            
            V[t][y] = max_prob
            prev_best_state[y][t] = best_prev_state
        end
    end

    -- Find the most probable final state
    local max_prob = MIN_FLOAT
    local best_final_state

    for _, y in pairs(states) do
        if V[#obs][y] > max_prob then
            max_prob = V[#obs][y]
            best_final_state = y
        end
    end

    -- Build and return the most probable path
    local most_probable_path = {best_final_state}
    local current_best_state = best_final_state

    for t = #obs, 2, -1 do
        current_best_state = prev_best_state[current_best_state][t]
        table.insert(most_probable_path, 1, current_best_state)
    end

    return most_probable_path
end

local function cut(sentence, start_p, trans_p, emit_p)
	local s_res = {}
	-- 可不可以直接返回表
	for i in string.gmatch(sentence, "[%z\1-\127\194-\244][\128-\191]*") do
		table.insert(s_res, i)
	end
	local pos_list = viterbi(s_res, { "B", "M", "E", "S" }, start_p, trans_p, emit_p)
	local result = {}
	local begin, nexti = 1, 1
	local sentence_length = #s_res
	for i = 1, sentence_length do
		local char = s_res[i]
		local pos = pos_list[i]
		if pos == "B" then
			begin = i
		elseif pos == "E" then
			local res = {}
			for _, v in pairs({ unpack(s_res, begin, i) }) do
				table.insert(res, v)
			end
			local val = table.concat(res)
      result[#result] = val
			nexti = i + 1
		elseif pos == "S" then
			result[#result + 1] = char
			nexti = i + 1
		end
	end
	if nexti <= sentence_length then
    result[#result] = s_res[nexti]
	end
	return result
end

M.lcut = function(sentence)
  return cut(sentence,  start, trans, emit)
end
-- local Force_Split_Words = {}
-- function contains(table, val)
--    for _, value in ipairs(table) do
--       if value == val then
--          return true
--       end
--    end
--    return false
-- end

function M.cut(sentence)
	local blocks = ut.splitWithSimilarCharacters(sentence)
	local result = {}
	for _, blk in ipairs(blocks) do
		if ut.isAllChinese(blk) then
      local l = M.lcut(blk)
      for _, word in pairs(l) do
        result[#result + 1] = word
      end
			-- for _, word in ipairs(M.lcut(blk)) do
			-- 	result[#result + 1] = word
			-- end
		else
			for _, word in ipairs(ut.splitString(blk)) do
				result[#result + 1] = word
			end
		end
	end
	return result
end
-- local t = os.clock()
-- for i =1, 100000 do
--   M.cut("韩冰是个")
-- end
-- print(os.clock() -t)
return M
