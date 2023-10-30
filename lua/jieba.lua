-- 字典存哪里的问题，在哪个文件夹下面有txt才能读，目前，目前在home下面
-- HMM问题
-- 有些地方可以用尾递归优化
-- -- 学习动态规划到底是啥
local M = {}
local st = require "stringtools"
local utf8 = require 'lua-utf8'

local p = '[%z\1-\127\194-\244][\128-\191]*'
local pat_punc = "[，。？！；/（）【】]"

local function keyInTable(table, key)
  return table[key] ~= nil
end

local function is_punctuation(char)
  if utf8.match(char, pat_punc)~= nil then
    return true
  else
    return false
  end
end

local gen_pfdict = function ()
  local starttime = os.clock()
  local f = io.open("dict.txt", "r")
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
      lfreq[ch] = 0.000001
      end
    end
    line = f:read()
  end
  f:close()
  local endtime = os.clock()
  print("loading took " .. endtime - starttime .. " seconds")
  return lfreq,ltotal
end

local Freq,Total = gen_pfdict()
local logtotal = math.log(Total) -- 17.9

for i,v in pairs(Freq) do
  Freq[i] = math.log(v) - logtotal
end

local get_DAG = function(sentence)
  local DAG = {}
  local tmplist = {}
  local N = st.len(sentence)
  local frag = ''
  for k = 1, N do
    local i = k
    frag = st.sub(sentence,k,k)
    while i <= N and keyInTable(Freq, frag) do
      tmplist[#tmplist+1] = i
      i = i + 1
      frag = st.sub(sentence,k,i)
    end
    if #tmplist == 0 then
      tmplist[#tmplist+1] = k
    end
    DAG[k] = tmplist
    tmplist = {}
  end
  return DAG
end


local calc = function (sentence, DAG)
  local N = st.len(sentence)
  local route = {}
  route[N+1] = {0,0}
  for i = N, 1, -1 do
    local tmp_list = {}
    for j = 1, #DAG[i] do
      local x = DAG[i][j]
      tmp_list[#tmp_list+1] = {Freq[st.sub(sentence,i,x)] or -logtotal + route[x+1][1]
,x}
    end
    route[i] = st.max_of_array(tmp_list)
    end
  return route
end

local iter_cut_all = function (sentence)
  local DAG = get_DAG(sentence)
  local old_j = -1
  for k,v in ipairs(DAG) do
    if #v == 1 and k > old_j then
      coroutine.yield(st.sub(sentence,k,v[1]))
      old_j = v[1]
    else
      for _,j in ipairs(v) do
        if j > k then
          coroutine.yield(st.sub(sentence,k,j))
          old_j = j
        end
      end
    end
  end
end

local iter_cut_no_hmm = function (sentence)
  local DAG = get_DAG(sentence)
  local route = calc(sentence, DAG)
  local x = 1
  local N = st.len(sentence)
  local buf = ''
  while x <= N do
    local y = route[x][2]
    local l_word = st.sub(sentence, x, y)
    if st.len(l_word) == 1 and st.isEng(l_word) then
      buf = buf .. l_word
      x = y + 1
    else
      if st.len(buf) > 0 then
        coroutine.yield(buf)
        buf = ''
      end
      coroutine.yield(l_word)
      x = y + 1
    end
  end
  if st.len(buf) > 0 then
    coroutine.yield(buf)
    buf = ''
    x = x + 1
  end
end

local function cut_no_hmm(sentence)
  return coroutine.wrap(function () iter_cut_no_hmm(sentence) end)
end

local function cut_all(sentence)
  return coroutine.wrap(function () iter_cut_all(sentence) end)
end
local function split_punctuation(sentence)
  local blocks = {}
  local buf = ''
  for i = 1, st.len(sentence) do
    local char = st.sub(sentence,i,i)
    if is_punctuation(char) then
      blocks[#blocks+1] = buf..char
      buf = ''
    else buf = buf .. char
    end
  end
  if st.len(buf) > 0 then
    blocks[#blocks+1] = buf
  end
  return blocks
end

local select_cut = function (sentence, all, HMM)
  local cutfunc
  if all then
    cutfunc = cut_all
  elseif HMM then
    -- cutfunc = cut_DAG
      else
    cutfunc = cut_no_hmm
  end
  -- sentence = sentence .. "，"
  local blocks = split_punctuation(sentence)
  for _,v in ipairs(blocks) do
    for i in cutfunc(v) do
      coroutine.yield(i)
    end
  end
end

M.cut = function(sentence,all,HMM)
  local co = coroutine.create(function () select_cut(sentence, all, HMM) end)
  return function ()
    local _, res = coroutine.resume(co)
    return res
  end
end

return M
