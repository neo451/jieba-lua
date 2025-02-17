local M = {}
local ut = require("jieba.utils")
local utf8 = require("jieba.utf8")
local hmm = require("jieba.hmm")
local p = "[%z\1-\127\194-\244][\128-\191]*"

local gen_pfdict = function(file)
   local f = io.open(file, "r")
   local lfreq = {}
   local ltotal = 0
   if f == nil then
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

local dict = gen_pfdict("dict/dict.txt") or require("jieba.dict")

local total = 60101967

logtotal = math.log(total)

for i, v in pairs(dict) do
   dict[i] = math.log(v) - logtotal
end

local get_DAG = function(sentence)
   local DAG = {}
   local tmplist = {}
   local N = utf8.len(sentence)
   -- local tab = ut.split_char(sentence)
   -- local N = #tab
   local frag = ""
   for k = 1, N do
      local i = k
      -- frag = tab[k]
      frag = ut.sub(sentence, k, k)
      while i <= N and dict[frag] do
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
   local N = utf8.len(sentence)
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
--
-- local function cut_all_iterator(sentence)
--    local DAG = get_DAG(sentence)
--    local old_j = 0
--    local k, v = 1, nil -- Initialize to start at the beginning of the DAG
--    local v_index = 0 -- Tracker for the current index in the value table (v)
--
--    return function()
--       while k <= #DAG do
--          -- When we need to move to the next set of end positions or start the loop
--          if not v or v_index >= #v then
--             k = k + 1
--             if k > #DAG then
--                return nil
--             end -- End of DAG, stop iteration
--             v = DAG[k]
--             v_index = 1
--          else
--             v_index = v_index + 1 -- Move to the next end position in the current set
--          end
--
--          for i = v_index, #v do
--             local j = v[i]
--             if j > k and j > old_j then -- Ensure non-overlapping segments
--                old_j = j -- Update the last used endpoint
--                v_index = i -- Update v_index for the next iteration
--                return sentence:sub(k, j) -- Using native Lua substring operation
--             end
--          end
--       end
--    end
-- end

-- for v in cut_all_iterator("我是中国人") do
--    print(v)
-- end
--
local cut_no_hmm = function(sentence)
   local DAG = get_DAG(sentence)
   local route = calc(sentence, DAG)
   local x = 1
   local N = utf8.len(sentence)
   local buf = ""
   local res = {}
   while x <= N do
      local y = route[x][2]
      local l_word = ut.sub(sentence, x, y)
      if utf8.len(l_word) == 1 and ut.is_eng(l_word) then
         buf = buf .. l_word
         x = y + 1
      else
         if utf8.len(buf) > 0 then
            res[#res + 1] = buf
            buf = ""
         end
         res[#res + 1] = l_word
         x = y + 1
      end
   end
   if utf8.len(buf) > 0 then
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
   local N = utf8.len(sentence)
   local buf = ""
   local res = {}
   while x <= N do
      local y = route[x][2]
      local l_word = ut.sub(sentence, x, y)
      if y == x then
         buf = buf .. l_word
      else
         if buf ~= "" then
            if utf8.len(buf) == 1 then
               res[#res + 1] = buf
               buf = ""
            elseif not dict[buf] then
               local recognized = hmm.cut(buf)
               for _, word in ipairs(recognized) do
                  res[#res + 1] = word
               end
            else
               for i = 1, utf8.len(buf) do
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
      if utf8.len(buf) == 1 then
         res[#res + 1] = buf
      elseif not dict[buf] then
         local recognized = hmm.cut(buf)
         for _, word in ipairs(recognized) do
            res[#res + 1] = word
         end
      else
         for i = 1, utf8.len(buf) do
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

return M
