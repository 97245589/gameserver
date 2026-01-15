local require = require
require "common.func.tool"
local skynet = require "skynet"

local rank = function()
    local lrank = require "lgame.rank"
end

local zstd = function()
    local zstd = require "common.func.zstd"
end

skynet.start(function()
    zstd()
    skynet.exit()
end)
