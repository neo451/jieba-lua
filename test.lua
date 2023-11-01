local jieba = require("jieba")


for i in jieba.cut("韩冰是个",false,true) do
    print(i)
end
