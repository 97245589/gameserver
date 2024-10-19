local require, print, collectgarbage = require, print, collectgarbage
local table, pairs, ipairs = table, pairs, ipairs

local zstd = require "common.util.zstd"
require "common.util.util"

local ret = {}

local cmp_func = function(lhs, rhs)
    return lhs[2] > rhs[2]
end

ret.info_str = function(obj)
    local arr = {}
    for k, v in pairs(obj) do
        table.insert(arr, {k, #zstd.encode(v)})
    end
    table.sort(arr, cmp_func)
    return arr
end

ret.info_mem = function(obj)
    local clone = clone
    local arr = {}
    for k, v in pairs(obj) do
        collectgarbage("collect")
        local m1 = collectgarbage("count")
        local tmp = clone(v)
        table.insert(arr, {k, collectgarbage("count") - m1})
    end
    table.sort(arr, cmp_func)
    return arr
end

return ret
