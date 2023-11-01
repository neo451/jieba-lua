-- 字典存哪里的问题，在哪个文件夹下面有txt才能读，目前，目前在home下面
-- 有些地方可以用尾递归优化
-- -- 学习动态规划到底是啥
local M = {}
local ut = require "utils"
local hmm = require "hmm"
local p = '[%z\1-\127\194-\244][\128-\191]*'

local function keyInTable(table, key)
  return table[key] ~= nil
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
      lfreq[ch] = 0
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
  local N = ut.len(sentence)
  local frag = ''
  for k = 1, N do
    local i = k
    frag = ut.sub(sentence,k,k)
    while i <= N and keyInTable(Freq, frag) do
      tmplist[#tmplist+1] = i
      i = i + 1
      frag = ut.sub(sentence,k,i)
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
  local N = ut.len(sentence)
  local route = {}
  route[N+1] = {0,0}
  for i = N, 1, -1 do
    local tmp_list = {}
    for j = 1, #DAG[i] do
      local x = DAG[i][j]
      tmp_list[#tmp_list+1] = {(Freq[ut.sub(sentence,i,x)] or 1) + route[x+1][1]
,x}
    end
    route[i] = ut.max_of_array(tmp_list)
    end
  return route
end

local iter_cut_all = function (sentence)
  local DAG = get_DAG(sentence)
  local old_j = -1
  for k,v in ipairs(DAG) do
    if #v == 1 and k > old_j then
      coroutine.yield(ut.sub(sentence,k,v[1]))
      old_j = v[1]
    else
      for _,j in ipairs(v) do
        if j > k then
          coroutine.yield(ut.sub(sentence,k,j))
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
  local N = ut.len(sentence)
  local buf = ''
  while x <= N do
    local y = route[x][2]
    local l_word = ut.sub(sentence, x, y)
    if ut.len(l_word) == 1 and ut.isEng(l_word) then
      buf = buf .. l_word
      x = y + 1
    else
      if ut.len(buf) > 0 then
        coroutine.yield(buf)
        buf = ''
      end
      coroutine.yield(l_word)
      x = y + 1
    end
  end
  if ut.len(buf) > 0 then
    coroutine.yield(buf)
    buf = ''
    x = x + 1
  end
end

local function iter_cut_hmm(sentence)
    local DAG = get_DAG(sentence)
    local route = calc(sentence, DAG)
    local x = 1
    local N = ut.len(sentence)
    local buf = ''
    while x <= N do
        local y = route[x][2]
        local l_word = ut.sub(sentence, x, y)
        if y == x then
            buf = buf .. l_word
        else
            if buf ~= "" then
                if ut.len(buf) == 1 then --应该是数字之类
                  -- print("1",buf)
                    coroutine.yield(buf)
                    buf = ""
                elseif not Freq[buf] then
                    local recognized = hmm.cut(buf)
                    for _, t in ipairs(recognized) do
                      coroutine.yield(t)
                      -- print("2",t)
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
            -- print("3",l_word)
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
  return coroutine.wrap(function () iter_cut_hmm(sentence) end)
end

local function cut_no_hmm(sentence)
  return coroutine.wrap(function () iter_cut_no_hmm(sentence) end)
end

local function cut_all(sentence)
  return coroutine.wrap(function () iter_cut_all(sentence) end)
end

local _cut = function (sentence, all, HMM)
  local cutfunc
  if all then
    cutfunc = cut_all
  elseif HMM then
    cutfunc = cut_hmm
  else
    cutfunc = cut_no_hmm
  end
  -- sentence = sentence .. "，"
  local blocks = ut.split_punctuation(sentence)
  for _,v in ipairs(blocks) do
    for i in cutfunc(v) do
      coroutine.yield(i)
    end
  end
end

M.cut = function(sentence,all,HMM)
  local co = coroutine.create(function () _cut(sentence, all, HMM) end)
  return function ()
    local _, res = coroutine.resume(co)
    return res
  end
end

return M
