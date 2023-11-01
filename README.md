# jieba-lua
结巴分词lua版，结巴分词 是由 @fxsjy 使用 Python 编写的中文分词组件，jieba-lua 是结巴分词的 lua 语言实现。

lua使用jieba理应调用cppjiaba性能较优，本项目just for fun

正在施工中

## 安装
- 自动安装：待施工
- 手动安装：克隆到本地项目文件夹中
- require("jieba") 来引用

## 使用

``` lua
local jieba = require("jieba")

-- 精确模式
local tmp = ""
for i in jieba.cut("我来到北京人民大学",false,false) do
  tmp = tmp ..i.." /"
end
print("【精确模式】："..tmp)

tmp = ""
-- 全模式
for i in jieba.cut("南京市长江大桥",true,true) do
  tmp = tmp ..i.." /"
end
print("【全模式】："..tmp)

tmp = ""
-- 新词识别
for i in jieba.cut("他来到了网易杭研大厦",true,true) do
  tmp = tmp ..i.." /"
end
print("【新词识别】："..tmp)
```

输出结果：

```
【精确模式】： 我 / 来到 / 北京 / 人民 / 大学 /

【全模式】： 南京 / 南京市 / 京市 / 市长 / 长江 / 大桥 /

【新词识别】： 他 / 来到 / 了 / 网易 / 杭 / 研 / 大厦 /  --- 还不太灵，算法有问题
```
