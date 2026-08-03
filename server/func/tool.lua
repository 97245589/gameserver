local ltool = require "lgame.tool"

return {
    clone = ltool.clone,
    tblen = ltool.tblen,
    crc16 = ltool.crc16,
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
