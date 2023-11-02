local M = {}
local MIN_FLOAT = -3.14e100
local start = require("prob_start")
local emit = require("prob_emit")
local trans = require("prob_trans")
local ut = require("utils")
local utf8 = require("lua-utf8")
-- add forcesplit later

local PrevStatus = {
	["B"] = { "E", "S" },
	["M"] = { "M", "B" },
	["S"] = { "S", "E" },
	["E"] = { "B", "M" },
}

local function viterbi(obs, states, start_p, trans_p, emit_p)
	local V = { {} } -- tabular
	local path = {}
	for _, y in pairs(states) do -- init
		V[1][y] = start_p[y] + (emit_p[y][obs[1]] or MIN_FLOAT)
		path[y] = { y }
	end
	for t = 2, #obs do
		V[t] = {}
		local newpath = {}
		for _, y in pairs(states) do
			local em_p = (emit_p[y][obs[t]] or MIN_FLOAT)
			local prob, state = nil, PrevStatus[y][1]
			local max_prob = MIN_FLOAT
			for _, y0 in pairs(PrevStatus[y]) do
				local tr_p = trans_p[y0][y] or MIN_FLOAT
				local prob0 = V[t - 1][y0] + tr_p + em_p
				if prob0 > max_prob then
					max_prob = prob0
					state = y0
				end
			end
			prob = max_prob
			V[t][y] = prob
			newpath[y] = {}
			for _, p in pairs(path[state]) do
				table.insert(newpath[y], p)
			end
			table.insert(newpath[y], y)
		end
		path = newpath
	end

	local prob, state = nil, "E"
	local max_prob = MIN_FLOAT
	for _, y in pairs({ "E", "S" }) do
		if V[#obs][y] > max_prob then
			max_prob = V[#obs][y]
			state = y
		end
	end
	prob = max_prob

	return prob, path[state]
end

local function cut(sentence, start_p, trans_p, emit_p)
	local s_res = {}
	-- 可不可以直接返回表
	for i in string.gmatch(sentence, "[%z\1-\127\194-\244][\128-\191]*") do
		table.insert(s_res, i)
	end
	local prob, pos_list = viterbi(s_res, { "B", "M", "E", "S" }, start_p, trans_p, emit_p)
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
			coroutine.yield(val)
			table.insert(result, val)
			nexti = i + 1
		elseif pos == "S" then
			coroutine.yield(char)
			result[#result + 1] = char
			nexti = i + 1
		end
	end
	if nexti <= sentence_length then
		table.insert(result, s_res[nexti])
		coroutine.yield(s_res[nexti])
	end
	return result
end

local _cut = function(sentence)
	local co = coroutine.create(function()
		cut(sentence, start, trans, emit)
	end)
	return function()
		local _, res = coroutine.resume(co)
		return res
	end
end

M.lcut = function(sentence)
	local res = {}
	for i in _cut(sentence) do
		table.insert(res, i)
	end
	return res
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
			for _, word in ipairs(M.lcut(blk)) do
				result[#result + 1] = word
			end
		else
			for _, word in ipairs(ut.splitString(blk)) do
				result[#result + 1] = word
			end
		end
	end
	return result
end

return M