local M = {}

-- 判断utf8字符byte长度
local chsize = function ( char )
    if not char then
        --print("not char")
        return 0
    elseif char > 240 then
        return 4
    elseif char > 225 then
        return 3
    elseif char > 192 then
        return 2
    else
        return 1
    end
end

M.sub = function( str, startChar, endChar )
    local startIndex = 1
    local numChars = endChar - startChar + 1
    while startChar > 1 do
        local char = string.byte(str, startIndex)
        startIndex = startIndex + chsize(char)
        startChar = startChar - 1
    end

    local currentIndex = startIndex

    while numChars > 0 and currentIndex <= #str do
        local char = string.byte(str, currentIndex)
        currentIndex = currentIndex + chsize(char)
        numChars = numChars -1
    end
    return str:sub(startIndex, currentIndex - 1), numChars
end

-- 计算utf8字符串字符数, 各种字符都按一个字符计算
M.len = function( str )
    local len = 0
    local currentIndex = 1
    while currentIndex <= #str do
        local char = string.byte(str, currentIndex)
        currentIndex = currentIndex + chsize(char)
        len = len +1
    end
    return len
end


M.isEng = function (char)
  if string.find(char, "[a-zA-Z0-9]") then
    return true
  else
    return false
  end
end

local function dump(o)
   if type(o) == 'table' then
      local s = '{ '
      for k,v in pairs(o) do
         if type(k) ~= 'number' then k = '"'..k..'"' end
         s = s .. dump(v) .. ','
      end
      return s .. '} '
   else
      return tostring(o)
  end
end

M.print = function (o)
  print(dump(o))
end

local compare =  function(a,b)
  if a[1] < b[1] then
    return true
  elseif a[1] > b[1] then
    return false
end
end

M.max_of_array = function (t)
  table.sort(t, compare)
  return t[#t]
end

M.keyInTable = function (table,key)
  for k,_ in pairs(table) do
    if k == key then
      return true
    end
  end
  return false
end
return M
