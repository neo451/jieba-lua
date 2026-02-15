# wordmotion.nvim

A lua library to simulate vim's word motion.
It is created for jieba.nvim.

`test.txt`:

```text
hello, world!
你好，世界！
こんにちわ，世界！
```

```lua
local Motion = require "wordmotion.jieba".Motion
local motion = Motion:from_path"/the/path/of/test.txt"
-- |你好，世界！
local pos = { 2, 0 }

-- press 1w
pos = motion:get_position(1, true, pos)
-- 你好|，世界！

-- press 1ge
pos = motion:get_position(-1, false, pos)
-- 你|好，世界！

-- press 1b
pos = motion:get_position(-1, true, pos)
-- |你好，世界！

-- press 1e
pos = motion:get_position(1, false, pos)
-- 你|好，世界！
```

Except `w/b/e/ge`, we also provide `(/)/g(/g)`.
You can install this plugin to get it!

## Install

### rocks.nvim

#### Command style

```vim
:Rocks install wordmotion.nvim
```

#### Declare style

`~/.config/nvim/rocks.toml`:

```toml
[plugins]
"wordmotion.nvim" = "scm"
```

Then

```vim
:Rocks sync
```

or:

```sh
$ luarocks --lua-version 5.1 --local --tree ~/.local/share/nvim/rocks install wordmotion.nvim
# ~/.local/share/nvim/rocks is the default rocks tree path
# you can change it according to your vim.g.rocks_nvim.rocks_path
```
