local MIN_FLOAT = -3.14e100
local st = require("stringtools")
-- local start_p = require ('prob_start') 
-- local emit_p = require ('prob_emit')
-- local trans_p = require ('prob_trans')

local start = {
  ['B'] = -0.6,
  ['M'] = -1.2,
  ['E'] = -1.0,
  ['S'] = -0.5
}


local emit = {
  ['B'] = {
    ['韩'] = -0.1, -- 假设比较高的概率
    ['冰'] = -3.0,
    ['是'] = -3.0,
    ['个'] = -3.0
  },
  ['M'] = {
    ['韩'] = -3.0,
    ['冰'] = -3.0,
    ['是'] = -3.0,
    ['个'] = -3.0
  },
  ['E'] = {
    ['韩'] = -3.0,
    ['冰'] = -0.1, -- 假设比较高的概率
    ['是'] = -3.0,
    ['个'] = -3.0 
  },
  ['S'] = {
    ['韩'] = -3.0,
    ['冰'] = -3.0,
    ['是'] = -0.1, -- 假设比较高的概率
    ['个'] = -0.1  -- 假设比较高的概率
  },
}

local trans = {
  ['B'] = {
    ['B'] = -1.2,
    ['M'] = -0.4,
    ['E'] = -0.6,
    ['S'] = -1.0
  },
  ['M'] = {
    ['B'] = -1.2,
    ['M'] = -0.4,
    ['E'] = -0.6,
    ['S'] = -1.0
  },
  ['E'] = {
    ['B'] = -0.6,
    ['M'] = -1.2,
    ['E'] = -1.0,
    ['S'] = -0.4
  },
  ['S'] = {
    ['B'] = -0.6,
    ['M'] = -1.2,
    ['E'] = -1.0,
    ['S'] = -0.4
  }
}

local function viterbi(obs, states, start_p, trans_p, emit_p)
    local V = {{}}  -- tabular
    local path = {}
    for _, y in pairs(states) do  -- init
        V[1][y] = start_p[y] + emit_p[y][obs[1]] or MIN_FLOAT
        path[y] = {y}
    end
    for t = 2, #obs do
        V[t] = {}
        local newpath = {}
        for _, y in pairs(states) do
            local em_p = emit_p[y][obs[t]] or MIN_FLOAT
            local prob, state = nil, nil
            local max_prob = MIN_FLOAT
            for _, y0 in pairs(states) do
                local prob0 = V[t - 1][y0] + (trans_p[y0][y] or MIN_FLOAT) + em_p
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

    local prob, state = nil, nil
    local max_prob = MIN_FLOAT
    for _, y in pairs({'E', 'S'}) do
        if V[#obs][y] > max_prob then
            max_prob = V[#obs][y]
            state = y
        end
    end
    prob = max_prob

    return prob, path[state]
end

local function cut(sentence, start_p, trans_p, emit_p)
  local prob, pos_list = viterbi(sentence, {'B', 'M', 'E', 'S'}, start_p, trans_p, emit_p)
  local result = {}
  local begin, nexti = 1, 1
  local sentence_length = #sentence
  for i = 1, sentence_length do
    local char = sentence[i]
    -- print(char)
    local pos = pos_list[i]
    if pos == 'B' then
      begin = i
    elseif pos == 'E' then
      local res = {}
      for _,v in pairs({unpack(sentence, begin, i)}) do
        table.insert(res, v)
      end
      local val = table.concat(res)
      table.insert(result, val)
      nexti = i + 1
    elseif pos == 'S' then
      result[#result+1] = char
      nexti = i + 1
    end
  end

  if nexti <= sentence_length then
    table.insert(result, sentence[nexti])
  end

  return result
end

local sentence = "韩冰是个"
local res = {}

for i in string.gmatch(sentence, "[%z\1-\127\194-\244][\128-\191]*") do
  table.insert(res, i)
end

-- 调用切分函数
local result = cut(res, start, trans, emit)

-- 以空格分隔的字符串形式输出切分结果
local segmented_sentence = table.concat(result, "｜")
print(segmented_sentence)
