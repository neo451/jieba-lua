# jieba-lua

结巴分词lua版，结巴分词 是由 @fxsjy 使用 Python 编写的中文分词组件，jieba-lua 是结巴分词的 lua 语言实现。

基于结巴中文分词的单词跳转，基于[jieba-lua](https://github.com/noearc/jieba-lua), 好处是比原版 jieba 快, 但并不会比采用 cppjieba 的 [jieba.nvim](https://github.com/neo451/jieba.nvim) 快, 不过完全够用, 且不需要本地编译，插件逻辑来自[jieba.vim](https://github.com/kkew3/jieba.vim)

## 安装

lazy.nvim:

```lua
{'noearc/jieba-lua', opts = {} },
```

## 设置

默认 keymap, 强化了 neovim 的 b, w, e, ge, 暂无数字修饰

```lua
vim.keymap.set({'x', 'n'}, 'B', '<cmd>lua require("jieba_nvim").wordmotion_B()<CR>', {noremap = false, silent = true})
vim.keymap.set({'x', 'n'}, 'b', '<cmd>lua require("jieba_nvim").wordmotion_b()<CR>', {noremap = false, silent = true})
vim.keymap.set({'x', 'n'}, 'w', '<cmd>lua require("jieba_nvim").wordmotion_w()<CR>', {noremap = false, silent = true})
vim.keymap.set({'x', 'n'}, 'W', '<cmd>lua require("jieba_nvim").wordmotion_W()<CR>', {noremap = false, silent = true})
vim.keymap.set({'x', 'n'}, 'E', '<cmd>lua require("jieba_nvim").wordmotion_E()<CR>', {noremap = false, silent = true})
vim.keymap.set({'x', 'n'}, 'e', '<cmd>lua require("jieba_nvim").wordmotion_e()<CR>', {noremap = false, silent = true})
vim.keymap.set({'x', 'n'}, 'ge', '<cmd>lua require("jieba_nvim").wordmotion_ge()<CR>', {noremap = false, silent = true})
vim.keymap.set({'x', 'n'}, 'gE', '<cmd>lua require("jieba_nvim").wordmotion_gE()<CR>', {noremap = false, silent = true})
```

可选 keymap, 模拟了 neovim 的 text object w, 可调用以下三个函数, 具体 keymap 可根据偏好自行添加

```lua
vim.keymap.set('n', 'ce', ":lua require'jieba_nvim'.change_w()<CR>", {noremap = false, silent = true})
vim.keymap.set('n', 'de', ":lua require'jieba_nvim'.delete_w()<CR>",  {noremap = false, silent = true})
vim.keymap.set('n', '<leader>w' , ":lua require'jieba_nvim'.select_w()<CR>", {noremap = false, silent = true})
```

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
for i in jieba.cut("他来到了网易杭研大厦",false,true) do
  tmp = tmp ..i.." /"
end
print("【新词识别】："..tmp)
```

输出结果：

```
【精确模式】： 我 / 来到 / 北京 / 人民 / 大学 /

【全模式】： 南京 / 南京市 / 京市 / 市长 / 长江 / 大桥 /

【新词识别】： 他 / 来到 / 了 / 网易 / 杭研 / 大厦 /
```

## 性能
- 待测试
