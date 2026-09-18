local ltool = require "lgame.tool"
local skynet = require "skynet"

print = skynet.error
dump = ltool.dump

local M = {}
M.clone = ltool.clone
M.tblen = ltool.tblen
M.crc16 = ltool.crc16
M.compress = ltool.zstd_compress
M.decompress = ltool.zstd_decompress

M.split = function(str, sp)
    sp = sp or " "
    if type(sp) == "number" then
        sp = string.char(sp)
    end

    local patt = string.format("[^%s]+", sp)
    local arr = {}
    for k in string.gmatch(str, patt) do
        table.insert(arr, k)
    end
    return arr
end

return M
