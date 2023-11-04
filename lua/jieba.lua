local M = {}
local ut = require("jb_utils")
local hmm = require("hmm")
local dict = require("dict")
local p = "[%z\1-\127\194-\244][\128-\191]*"

local gen_pfdict = function(file)
	local f = io.open(file, "r")
	local lfreq = {}
	local ltotal = 0
	if f == nil then
		print("file not found")
		return
	end
	local line = f:read()
	while line do
		local word, freq = string.match(line, "(%S+)%s(%d+)")
		lfreq[word] = freq
		ltotal = ltotal + freq
		for ch in string.gmatch(word, p) do
			if lfreq[ch] == nil then
				lfreq[ch] = 0
			end
		end
		line = f:read()
	end
	f:close()
	return lfreq, ltotal
end

-- local Freq, Total = gen_pfdict("dict.txt")

local Freq = dict
local Total = 60101967

if Total == nil then
  print("Empty dict")
else
  Logtotal = math.log(Total) -- 17.9
end

if Freq == nil then
  print("Empty dict")
else
  for i, v in pairs(Freq) do
    Freq[i] = math.log(v) - Logtotal
  end
end

local get_DAG = function(sentence)
	local DAG = {}
	local tmplist = {}
	local N = ut.len(sentence)
	local frag = ""
	for k = 1, N do
		local i = k
		frag = ut.sub(sentence, k, k)
		while i <= N and ut.keyInTable(Freq, frag) do
			tmplist[#tmplist + 1] = i
			i = i + 1
			frag = ut.sub(sentence, k, i)
		end
		if #tmplist == 0 then
			tmplist[#tmplist + 1] = k
		end
		DAG[k] = tmplist
		tmplist = {}
	end
	return DAG
end

local calc = function(sentence, DAG)
	local N = ut.len(sentence)
	local route = {}
	route[N + 1] = { 0, 0 }
	for i = N, 1, -1 do
		local tmp_list = {}
		for j = 1, #DAG[i] do
			local x = DAG[i][j]
			tmp_list[#tmp_list + 1] = { (Freq[ut.sub(sentence, i, x)] or 1) + route[x + 1][1], x }
		end
		route[i] = ut.max_of_array(tmp_list)
	end
	return route
end

local iter_cut_all = function(sentence)
	local DAG = get_DAG(sentence)
	local old_j = -1
	for k, v in ipairs(DAG) do
		if #v == 1 and k > old_j then
			coroutine.yield(ut.sub(sentence, k, v[1]))
			old_j = v[1]
		else
			for _, j in ipairs(v) do
				if j > k then
					coroutine.yield(ut.sub(sentence, k, j))
					old_j = j
				end
			end
		end
	end
end

local iter_cut_no_hmm = function(sentence)
	local DAG = get_DAG(sentence)
	local route = calc(sentence, DAG)
	local x = 1
	local N = ut.len(sentence)
	local buf = ""
	while x <= N do
		local y = route[x][2]
		local l_word = ut.sub(sentence, x, y)
		if ut.len(l_word) == 1 and ut.isEng(l_word) then
			buf = buf .. l_word
			x = y + 1
		else
			if ut.len(buf) > 0 then
				coroutine.yield(buf)
				buf = ""
			end
			coroutine.yield(l_word)
			x = y + 1
		end
	end
	if ut.len(buf) > 0 then
		coroutine.yield(buf)
		buf = ""
		x = x + 1
	end
end

local function iter_cut_hmm(sentence)
	local DAG = get_DAG(sentence)
	local route = calc(sentence, DAG)
	local x = 1
	local N = ut.len(sentence)
	local buf = ""
	while x <= N do
		local y = route[x][2]
		local l_word = ut.sub(sentence, x, y)
		if y == x then
			buf = buf .. l_word
		else
			if buf ~= "" then
				if ut.len(buf) == 1 then
					coroutine.yield(buf)
					buf = ""
				elseif not Freq[buf] then
					local recognized = hmm.cut(buf)
					for _, t in ipairs(recognized) do
						coroutine.yield(t)
					end
				else
					for i = 1, ut.len(buf) do
						local elem = ut.sub(buf, i, i)
						coroutine.yield(elem)
					end
				end
				buf = ""
			end
			coroutine.yield(l_word)
		end
		x = y + 1
	end

	if buf ~= "" then
		if ut.len(buf) == 1 then
			coroutine.yield(buf)
		elseif not Freq[buf] then
			local recognized = hmm.cut(buf)
			for _, t in ipairs(recognized) do
				coroutine.yield(t)
			end
		else
			for i = 1, ut.len(buf) do
				local elem = ut.sub(buf, i, i)
				coroutine.yield(elem)
			end
		end
	end
end

local function cut_hmm(sentence)
	return coroutine.wrap(function()
		iter_cut_hmm(sentence)
	end)
end

local function cut_no_hmm(sentence)
	return coroutine.wrap(function()
		iter_cut_no_hmm(sentence)
	end)
end

local function cut_all(sentence)
	return coroutine.wrap(function()
		iter_cut_all(sentence)
	end)
end

local _cut = function(sentence, all, HMM)
	local cutfunc
	if all then
		cutfunc = cut_all
	elseif HMM then
		cutfunc = cut_hmm
	else
		cutfunc = cut_no_hmm
	end
	local blocks = ut.splitWithSimilarCharacters(sentence)
	for _, v in ipairs(blocks) do
		for i in cutfunc(v) do
			coroutine.yield(i)
		end
	end
end

M.cut = function(sentence, all, HMM)
	local co = coroutine.create(function()
		_cut(sentence, all, HMM)
	end)
	return function()
		local _, res = coroutine.resume(co)
		return res
	end
end


M.lcut = function(sentence, all, HMM)
	local res = {}
	for i in M.cut(sentence, all, HMM) do
		res[#res + 1] = i
	end
	return res
end

return M
