local ltool = require "lgame.tool"
local lutil = require "lgame.util"

return {
    clone = ltool.clone,
    tblen = ltool.tblen,
    keys = ltool.keys,
    crc16 = lutil.crc16,
    compress = lutil.zstd_compress,
    decompress = lutil.zstd_decompress,
    split = function(str, sp)
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
}
