local crc = require "lutil.crc"

local ret = {}

ret.crc16 = function(v)
    return crc.crc16(v)
end

ret.crc32 = function(v)
    return crc.crc32(v)
end

return ret
