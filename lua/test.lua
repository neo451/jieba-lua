-- local jieba = require("jieba")
-- local profile = require("profile")



function read_file_lines(file_path)
    local lines = {}
    local file = io.open(file_path, "r")
    
    if not file then
        print("Error opening file:", file_path)
        return lines
    end

    for line in file:lines() do
        table.insert(lines, line)
    end
    
    file:close()
    return lines
end

test_text = read_file_lines("wc.txt")

print(test_text[1])

local test = "为了深入展现新时代“海上新广东”故事，更好地强信心、稳预期、促发展，10月30日至11月5日，由中央网信办网络传播局指导、广东省委网信办主办、南方新闻网承办的“向海图强看广东”大型网络主题宣传活动将联合100多名中央和省市重点网络媒体记者以及相关海洋经济领域专家学者、知名网络达人、自媒体创作者等，分东、西、中三条线路探访调研广东14个沿海城市。南方日报、南方网、南方+、粤学习客户端即日起推出“强信心 稳预期 促发展”系列报道之“向海图强·广东观察”，敬请垂注。" 

-- profile.start()
local n = os.clock()
for _,v in pairs(test_text) do
  print(v)
  -- for i in jieba.cut(v,true) do
  --     io.write(i.."/")
  -- end
end
-- print(os.clock()-n)
-- profile.stop()

-- print(profile.report(16))
