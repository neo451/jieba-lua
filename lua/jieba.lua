-- 字典存哪里的问题，在哪个文件夹下面有txt才能读，目前，目前在home下面
-- 中文regex问题,标点，也许就过滤标点就好了，反向解决，再读读源码
-- HMM问题
-- maybe 最终都改成迭代器, (更高效？）
-- 有些地方可以用尾递归优化
-- -- 学习动态规划到底是啥
local M = {}
local st = require "stringtools"
local utf8 = require 'lua-utf8'

  local p = '[%z\1-\127\194-\244][\128-\191]*'
local pat_punc = "[^，。？！；/（）【】]"


local function is_punctuation(char)
  if utf8.match(char, pat_punc)~= nil then
    return true
  else
    return false
  end
end

local gen_pfdict = function ()
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
    line = f:read()
  end
  f:close()
  return lfreq,ltotal
end

local Freq,Total = gen_pfdict()
local logtotal = math.log(Total) -- 17.9

local get_DAG = function(sentence)
  local DAG = {}
  local tmplist = {}
  local N = st.len(sentence)
  local frag = ''
  for k = 1, N do
    local i = k
    frag = st.sub(sentence,k,k)
    while i <= N and st.keyInTable(Freq, frag) do
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
    for _, x in ipairs(DAG[i]) do
      local tmp = st.sub(sentence,i,x)
      local freq = Freq[tmp] or 1
      local logfreq = math.log(freq)
      local logprob = logfreq - logtotal + route[x+1][1]
      table.insert(tmp_list, {logprob,x})
    end
    route[i] = st.max_of_array(tmp_list)
    end
  return route
end

local cut_all = function (sentence)
  local DAG = get_DAG(sentence)
  local old_j = -1
  local result = {}
  for k,v in ipairs(DAG) do
    if #v == 1 and k > old_j then
      local res = st.sub(sentence,k,v[1])
      result[#result+1] = res
      old_j = v[1]
    else
      for _,j in ipairs(v) do
        if j > k then
          local res2 = st.sub(sentence,k,j)
          result[#result+1] = res2
          old_j = j
        end
      end
    end
  end
  return result
end

local cut_DAG_NO_HMM = function (sentence)
  local result = {}
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
        result[#result+1] = buf
        buf = ''
      end
      table.insert(result,l_word)
      x = y + 1
    end
  end
  if st.len(buf) > 0 then
    result[#result+1] = buf
    buf = ''
    x = x + 1
  end
  return result
end

local cut_DAG = function ()
end


M.cut = function (sentence, all, HMM)
  local yieldval = {}
  local tmp = ""
  local cutfunc

  if all then
    cutfunc = cut_all
  elseif HMM then
    cutfunc = cut_DAG
      else
    cutfunc = cut_DAG_NO_HMM
  end
  return cutfunc(sentence)
  -- 暂时先放一个sep在后面
  -- sentence = sentence .. "，"
  -- local blocks = split_punctuation(sentence)
  -- for _,v in ipairs(blocks) do
  --   local tmplist = cut_DAG_NO_HMM(v)
  --   for _,w in ipairs(tmplist) do
  --     table.insert(yieldval, w)
  --   end
  -- end
end

return M
