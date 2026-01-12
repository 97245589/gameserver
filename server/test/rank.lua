require "common.tool.tool"
local skynet = require "skynet"
local random = math.random

local test = function()
    local lrank = require "lgame.rank"
end

skynet.start(function()
    test()
end)
