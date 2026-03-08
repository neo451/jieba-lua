package.path = package.path .. ';lua/?.lua;packages/lua-profile/lua/?.lua'

local profile = require("profile")
local data = {
	{
		name = "rjieba",
		jieba = require("rjieba").Jieba()
	},
	{
		name = "jieba.nvim",
		jieba = require("jieba.jieba").Jieba()
	},
	{
		name = "jieba-lua",
		jieba = require("jieba.jieba-lua").Jieba()
	}
}
local fs = require 'vim.fs'
local t = {}
local file = fs.joinpath(
	fs.dirname(debug.getinfo(1).source:match("@?(.*)")),
	"weicheng.txt"
)
for line in io.lines(file) do
	t[#t + 1] = line
end

for _, datum in ipairs(data) do
	profile.start()
	-- -- report for the top 10 functions, sorted by execution time
	local st = os.clock()
	-- for i = 1, 50 do
	for _, v in pairs(t) do
		datum.jieba:cut(v, true)
	end
	-- end
	datum.time = os.clock() - st
	-- execute code that will be profiled
	profile.stop()
	datum.report = profile.report(10)
end

for _, datum in ipairs(data) do
	print(("%s: %f s"):format(datum.name, datum.time))
	print(datum.report)
end

-- 23.11.10 65s --- sub50s
-- 23.11.13 weicheng 8.3 with lpeg for string and char spliting
