# lua-profile

cppjieba: 0.241448 s

 | #   | Function                      | Calls       | Time                     | Code                             |
 |-----|-------------------------------|-------------|--------------------------|----------------------------------|
 | 1   | cut                           | 247         | 0.237655                 | re/lua/5.1/cppjieba/jieba.lua:54 |

rjieba: 2.309668 s

 | #   | Function                      | Calls       | Time                     | Code                             |
 |-----|-------------------------------|-------------|--------------------------|----------------------------------|
 | 1   | cut                           | 247         | 2.305619                 | s/rjieba/lua/rjieba/jieba.lua:29 |

jieba-lua: 38.270958 s

 | #   | Function                      | Calls       | Time                     | Code                             |
 |-----|-------------------------------|-------------|--------------------------|----------------------------------|
 | 1   | cut                           | 247         | 38.269077                | lua/jieba/jieba.lua:29           |
 | 2   | cut                           | 247         | 38.267302                | lua/jieba/core.lua:219           |
 | 3   | cutfunc                       | 57233       | 26.452762                | lua/jieba/core.lua:166           |
 | 4   | cut                           | 27187       | 15.867914                | lua/jieba/hmm.lua:149            |
 | 5   | lcut                          | 42506       | 11.829314                | lua/jieba/hmm.lua:113            |
 | 6   | split_similar_char            | 27434       | 11.516583                | lua/jieba/utils.lua:73           |
 | 7   | viterbi                       | 21253       | 9.951794                 | lua/jieba/hmm.lua:68             |
 | 8   | calc                          | 57233       | 4.900068                 | lua/jieba.lua:65                 |
 | 9   | get_DAG                       | 57233       | 3.2722490000001          | lua/jieba/core.lua:40            |
 | 10  | is_chinese_char               | 402923      | 2.3445860000009          | lua/jieba/utils.lua:56           |
