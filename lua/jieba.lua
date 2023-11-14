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

local total = 60101967

logtotal = math.log(total)

for i, v in pairs(dict) do
	dict[i] = math.log(v) - logtotal
end

local get_DAG = function(sentence)
	local DAG = {}
	local tmplist = {}
	local N = ut.len(sentence)
  -- local tab = ut.split_char(sentence)
  -- local N = #tab
	local frag = ""
	for k = 1, N do
		local i = k
    -- frag = tab[k]
		frag = ut.sub(sentence, k, k)
		while i <= N and ut.key_in_table(dict, frag) do
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
			tmp_list[#tmp_list + 1] = { (dict[ut.sub(sentence, i, x)] or 1) + route[x + 1][1], x }
		end
		route[i] = ut.max_of_array(tmp_list)
	end
	return route
end

local cut_all = function(sentence)
	local DAG = get_DAG(sentence)
	local old_j = -1
	local res = {}
	for k, v in ipairs(DAG) do
		if #v == 1 and k > old_j then
			res[#res + 1] = ut.sub(sentence, k, v[1])
			old_j = v[1]
		else
			for _, j in ipairs(v) do
				if j > k then
					res[#res + 1] = ut.sub(sentence, k, j)
					old_j = j
				end
			end
		end
	end
	return res
end

local cut_no_hmm = function(sentence)
	local DAG = get_DAG(sentence)
	local route = calc(sentence, DAG)
	local x = 1
	local N = ut.len(sentence)
	local buf = ""
	local res = {}
	while x <= N do
		local y = route[x][2]
		local l_word = ut.sub(sentence, x, y)
		if ut.len(l_word) == 1 and ut.is_eng(l_word) then
			buf = buf .. l_word
			x = y + 1
		else
			if ut.len(buf) > 0 then
				res[#res + 1] = buf
				buf = ""
			end
			res[#res + 1] = l_word
			x = y + 1
		end
	end
	if ut.len(buf) > 0 then
		res[#res + 1] = buf
		buf = ""
		x = x + 1
	end
	return res
end

local function cut_hmm(sentence)
	local DAG = get_DAG(sentence)
	local route = calc(sentence, DAG)
	local x = 1
	local N = ut.len(sentence)
	local buf = ""
	local res = {}
	while x <= N do
		local y = route[x][2]
		local l_word = ut.sub(sentence, x, y)
		if y == x then
			buf = buf .. l_word
		else
			if buf ~= "" then
				if ut.len(buf) == 1 then
					res[#res + 1] = buf
					buf = ""
				elseif not dict[buf] then
					local recognized = hmm.cut(buf)
					for _, word in ipairs(recognized) do
						res[#res + 1] = word
					end
				else
					for i = 1, ut.len(buf) do
						local elem = ut.sub(buf, i, i)
						res[#res + 1] = elem
					end
				end
				buf = ""
			end
			res[#res + 1] = l_word
		end
		x = y + 1
	end

	if buf ~= "" then
		if ut.len(buf) == 1 then
			res[#res + 1] = buf
		elseif not dict[buf] then
			local recognized = hmm.cut(buf)
			for _, word in ipairs(recognized) do
				res[#res + 1] = word
			end
		else
			for i = 1, ut.len(buf) do
				local elem = ut.sub(buf, i, i)
				res[#res + 1] = elem
			end
		end
	end
	return res
end

M.lcut = function(sentence, all, HMM)
	local res = {}
	local cutfunc
	if all then
		cutfunc = cut_all
	elseif HMM then
		cutfunc = cut_hmm
	else
		cutfunc = cut_no_hmm
	end
	local blocks = ut.split_similar_char(sentence)
	for _, v in ipairs(blocks) do
		local words = cutfunc(v)
		for _, word in ipairs(words) do
			res[#res + 1] = word
		end
	end
	return res
end

-- print(vim.inspect(M.lcut("   - 人类与生俱来的东西不是口头言语，而是语言的机能 -》一个对应不同观念的不同符号构成的系统", false, true)))

return M
