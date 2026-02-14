# jieba-lua

[![readthedocs](https://shields.io/readthedocs/jieba-lua)](https://jieba-lua.readthedocs.io)
[![pre-commit.ci status](https://results.pre-commit.ci/badge/github/neo451/jieba-lua/main.svg)](https://results.pre-commit.ci/latest/github/neo451/jieba-lua/main)
[![github/workflow](https://github.com/neo451/jieba-lua/actions/workflows/main.yml/badge.svg)](https://github.com/neo451/jieba-lua/actions)

[![github/downloads](https://shields.io/github/downloads/neo451/jieba-lua/total)](https://github.com/neo451/jieba-lua/releases)
[![github/downloads/latest](https://shields.io/github/downloads/neo451/jieba-lua/latest/total)](https://github.com/neo451/jieba-lua/releases/latest)
[![github/issues](https://shields.io/github/issues/neo451/jieba-lua)](https://github.com/neo451/jieba-lua/issues)
[![github/issues-closed](https://shields.io/github/issues-closed/neo451/jieba-lua)](https://github.com/neo451/jieba-lua/issues?q=is%3Aissue+is%3Aclosed)
[![github/issues-pr](https://shields.io/github/issues-pr/neo451/jieba-lua)](https://github.com/neo451/jieba-lua/pulls)
[![github/issues-pr-closed](https://shields.io/github/issues-pr-closed/neo451/jieba-lua)](https://github.com/neo451/jieba-lua/pulls?q=is%3Apr+is%3Aclosed)
[![github/discussions](https://shields.io/github/discussions/neo451/jieba-lua)](https://github.com/neo451/jieba-lua/discussions)
[![github/milestones](https://shields.io/github/milestones/all/neo451/jieba-lua)](https://github.com/neo451/jieba-lua/milestones)
[![github/forks](https://shields.io/github/forks/neo451/jieba-lua)](https://github.com/neo451/jieba-lua/network/members)
[![github/stars](https://shields.io/github/stars/neo451/jieba-lua)](https://github.com/neo451/jieba-lua/stargazers)
[![github/watchers](https://shields.io/github/watchers/neo451/jieba-lua)](https://github.com/neo451/jieba-lua/watchers)
[![github/contributors](https://shields.io/github/contributors/neo451/jieba-lua)](https://github.com/neo451/jieba-lua/graphs/contributors)
[![github/commit-activity](https://shields.io/github/commit-activity/w/neo451/jieba-lua)](https://github.com/neo451/jieba-lua/graphs/commit-activity)
[![github/last-commit](https://shields.io/github/last-commit/neo451/jieba-lua)](https://github.com/neo451/jieba-lua/commits)
[![github/release-date](https://shields.io/github/release-date/neo451/jieba-lua)](https://github.com/neo451/jieba-lua/releases/latest)

[![github/license](https://shields.io/github/license/neo451/jieba-lua)](https://github.com/neo451/jieba-lua/blob/main/LICENSE)
[![github/languages](https://shields.io/github/languages/count/neo451/jieba-lua)](https://github.com/neo451/jieba-lua)
[![github/languages/top](https://shields.io/github/languages/top/neo451/jieba-lua)](https://github.com/neo451/jieba-lua)
[![github/directory-file-count](https://shields.io/github/directory-file-count/neo451/jieba-lua)](https://github.com/neo451/jieba-lua)
[![github/code-size](https://shields.io/github/languages/code-size/neo451/jieba-lua)](https://github.com/neo451/jieba-lua)
[![github/repo-size](https://shields.io/github/repo-size/neo451/jieba-lua)](https://github.com/neo451/jieba-lua)
[![github/v](https://shields.io/github/v/release/neo451/jieba-lua)](https://github.com/neo451/jieba-lua)

[![luarocks](https://img.shields.io/luarocks/v/freed-Wu/jieba)](https://luarocks.org/modules/freed-Wu/jieba)

基于结巴中文分词的单词跳转。结巴分词是由 @fxsjy 使用 Python 编写的中文分词组件，jieba-lua 是结巴分词的 lua 语言实现。比原版 jieba 快, 但并不会比采用 cppjieba 的 [jieba.nvim](https://github.com/neo451/jieba.nvim) 快, 不过完全够用, 且不需要本地编译，插件逻辑来自[jieba.vim](https://github.com/kkew3/jieba.vim)

[相关项目](https://github.com/neo451/jieba.nvim#related-projects)

## 安装

### rocks.nvim

#### Command style

```vim
:Rocks install jieba-lua
```

#### Declare style

`~/.config/nvim/rocks.toml`:

```toml
[plugins]
"jieba-lua" = "scm"
```

Then

```vim
:Rocks sync
```

or:

```sh
$ luarocks --lua-version 5.1 --local --tree ~/.local/share/nvim/rocks install jieba-lua
# ~/.local/share/nvim/rocks is the default rocks tree path
# you can change it according to your vim.g.rocks_nvim.rocks_path
```

### lazy.nvim

```lua
require("lazy").setup {
  spec = {
    { "neo451/jieba-lua", lazy = false },
  },
}
```

## 设置

默认 keymap, 强化了 neovim 的 b, w, e, ge, 支持数字修饰

## 使用

``` lua
local jieba = require("jieba.core")

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
