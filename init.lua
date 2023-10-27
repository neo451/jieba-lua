local M = {}
local st = require "stringtools"

-- 精准模式正则
local re_han_default = "" -- 汉字码、非空白字符
local re_skip_default = "" --换行或空白

-- 全局模式的正则
local re_han_cut_all = "" -- 全局模式 只包含汉字
local re_skip_cut_all = "" -- 字母数字+#

-- maybe 最终都改成迭代器



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

local get_DAG = function(sentence)
  local DAG = {}
  local N = st.len(sentence)
  for k = 1, N do
    local tmplist = {}
    local i = k
    local frag = st.sub(sentence,k,k)
    while i <= N and st.keyInTable(Freq, frag) do
      table.insert(tmplist, i)
      i = i + 1
      frag = st.sub(sentence,k,i)
    end
    if #tmplist == 0 then
      table.insert(tmplist, k)
    end
    DAG[k] = tmplist
  end
  return DAG
end

local calc = function (sentence, DAG)
  local N = st.len(sentence)
  local route = {}
  route[N+1] = {0,0}
  local logtotal = math.log(Total) -- 17.9
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
      table.insert(result, res)
      old_j = v[1]
    else
      for _,j in ipairs(v) do
        if j > k then
          local res2 = st.sub(sentence,k,j)
          table.insert(result, res2)
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
        table.insert(result,buf)
        buf = ''
      end
      table.insert(result,l_word)
      x = y + 1
    end
  end
  if st.len(buf) > 0 then
    table.insert(result, buf)
    buf = ''
    x = x + 1
  end
  return result
end

local isSep = function (w)
  if w == "，" then
    return true
end
end

M.cut = function (sentence, ifcut_all, ifHMM)
  -- ifcut_all = false
  -- ifHMM = false
  -- local cut_block = {}
  -- if ifcut_all then
  --   cut_block = cut_all()
  -- elseif ifHMM then
  --   -- cut_block = cut_DAG()
  -- else
  --   cut_block = cut_DAG_NO_HMM()
  -- end
  local yieldval = {}
  local blocks = {}
  local p = '[%z\1-\127\194-\244][\128-\191]*'
  local tmp = ""
  -- 暂时先放一个sep在后面
  sentence = sentence .. "，"
  for w in string.gmatch(sentence,p) do
    if not isSep(w) then
      tmp = tmp .. w
    else
      table.insert(blocks, tmp)
      tmp = ""
    end
  end
  for _,v in ipairs(blocks) do
    local tmplist = cut_DAG_NO_HMM(v)
    for _,w in ipairs(tmplist) do
      table.insert(yieldval, w)
    end
  end
  return yieldval
end

local test = M.cut("我爱北京天安门，南京市长江大桥，他撒大苏打",false,false)
st.print(test)

return M
