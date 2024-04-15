local jieba = require("jieba")
require("moon.all")

p(jieba.lcut("我来到北京人民大学", false, false))
-- 精确模式
-- local tmp = ""
-- for i in jieba.cut("我来到北京人民大学",false,false) do
--   tmp = tmp ..i.." /"
-- end
-- print("【精确模式】："..tmp)
--
-- tmp = ""
-- -- 全模式
-- for i in jieba.cut("南京市长江大桥",true,true) do
--   tmp = tmp ..i.." /"
-- end
-- print("【全模式】："..tmp)
--
-- tmp = ""
-- -- 新词识别
-- for i in jieba.cut("他来到了网易杭研大厦",false,true) do
--   tmp = tmp ..i.." /"
-- end
-- print("【新词识别】："..tmp)
