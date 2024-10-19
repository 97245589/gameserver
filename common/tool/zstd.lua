local skynet = require "skynet"
local zstd = require "lzstd"

local compress = zstd.zstd_compress;
local decompress = zstd.zstd_decompress;

local zstd_encode = function(val)
    return compress(skynet.packstring(val))
end

local zstd_decode = function(bin)
    return skynet.unpack(decompress(bin))
end
return {
    compress = compress,
    decompress = decompress,
    encode = zstd_encode,
    decode = zstd_decode
}
