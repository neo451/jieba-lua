# lua-profile

```sh
spec/bench/performance.lua
```

## Environment

- 11th Gen Intel(R) Core(TM) i5-1155G7 @ 2.50GHz
- Linux 6.17.8
- LuaJIT 2.1.1741730670
- cppjieba 5.6.3
- rjieba 0.0.3
- jieba-lua 0.1.1

## Results

cppjieba: 0.091479 s

 | #   | Function                      | Calls       | Time                     | Code                             |
 |-----|-------------------------------|-------------|--------------------------|----------------------------------|

rjieba: 0.453274 s

 | #   | Function                      | Calls       | Time                     | Code                             |
 |-----|-------------------------------|-------------|--------------------------|----------------------------------|

jieba-lua: 13.524105 s

 | #   | Function                      | Calls       | Time                     | Code                             |
 |-----|-------------------------------|-------------|--------------------------|----------------------------------|
 | 1   | cut                           | 247         | 13.523697                | lua/jieba/jieba.lua:29           |
 | 2   | cut                           | 247         | 13.522878                | lua/jieba.lua:219                |
 | 3   | split_similar_char            | 27434       | 7.292768                 | lua/jieba/utils.lua:73           |
 | 4   | cutfunc                       | 57233       | 6.240524                 | lua/jieba.lua:166                |
 | 5   | cut                           | 27187       | 2.832152                 | lua/jieba/hmm.lua:149            |
 | 6   | calc                          | 57233       | 1.797195                 | lua/jieba.lua:65                 |
 | 7   | lcut                          | 21253       | 1.574453                 | lua/jieba/hmm.lua:113            |
 | 8   | viterbi                       | 21253       | 1.192309                 | lua/jieba/hmm.lua:68             |
 | 9   | is_chinese_char               | 402923      | 0.89014400000075         | lua/jieba/utils.lua:56           |
 | 10  | get_DAG                       | 57233       | 0.88284699999992         | lua/jieba.lua:40                 |
