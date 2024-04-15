local jieba = require("lua.jieba.jieba")
local profile = require("profile")
local t = {}
for line in io.lines("weicheng.txt") do
	t[#t + 1] = line
end

-- profile.start()
-- -- report for the top 10 functions, sorted by execution time
local st = os.clock()
-- for i = 1, 50 do
for _, v in pairs(t) do
	jieba.lcut(v, false, true)
end
-- end
print(os.clock() - st)
-- execute code that will be profiled
-- profile.stop()
-- print(profile.report(10))

-- 23.11.10 65s --- sub50s
-- 23.11.13 weicheng 8.3 with lpeg for string and char spliting
