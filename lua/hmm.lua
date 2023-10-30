local MIN_FLOAT = -3.14e100
local start_p = require ('prob_start') 
local emit_p = require ('prob_emit')
local trans_p = require ('prob_trans')

local states = {'x','y','z'} --替换为你的实际状态
local obs = {'a','b','c','d'} --替换为你的实际观察序列



function viterbi(obs, states, start_p, trans_p, emit_p)
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


local prob, path = viterbi(obs, states, start_p, trans_p, emit_p)

-- 输出最大概率和对应的状态路径
print(prob)
print(unpack(path)) 



