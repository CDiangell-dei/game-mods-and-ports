local stringManipulation = {}

local utf8 = require('utf8')

function stringManipulation.splitWithDelimiters(str, ...)
    local function replace(s)
        return '\v' .. s .. '\v'
    end
    local delimiters
    if type(select(1, ...)) == 'table' then
        delimiters = select(1, ...)
    else
        delimiters = table.pack(...)
    end
    for _, key in pairs(delimiters) do
        str = string.gsub(str, '(' .. key .. ')', replace)
    end

    local t = {}
    for s in string.gmatch(str, '([^\v]+)') do
        table.insert(t, s)
    end
    return t
end

function stringManipulation.split(str, ...)
    local function replace(s)
        return '\v'
    end
    local delimiters
    if type(select(1, ...)) == 'table' then
        delimiters = select(1, ...)
    else
        delimiters = table.pack(...)
    end
    for _, key in pairs(delimiters) do
        str = string.gsub(str, '(' .. key .. ')', replace)
    end

    local t = {}
    for s in string.gmatch(str, '([^\v]+)') do
        table.insert(t, s)
    end
    return t
end

stringManipulation.codes = utf8.codes

stringManipulation.char = utf8.char

function stringManipulation.startsWith(str, start)
    local startLength = utf8.len(start)
    return string.sub(str, 1, startLength) == start
end

function stringManipulation.endsWith(str, ending)
    return string.match(str, ending .. '$') ~= nil
end

function stringManipulation.sub(str, from, to)
    local fromConverted = utf8.offset(str, from)
    local toConverted = utf8.offset(str, to)
    if not fromConverted then
        fromConverted = 1
    end
    if not toConverted then
        toConverted = string.len(str)
    end
    return string.sub(str, fromConverted, toConverted)
end

stringManipulation.len = utf8.len

return stringManipulation