local text = "这是一个中文字符串。"
local pattern = "[%z\194-\244][\128-\191]*" -- 匹配所有中文字符
for w in string.gmatch(text, pattern) do
  print(w)
end

