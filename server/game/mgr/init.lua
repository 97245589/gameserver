local require = require
local skynet = require "skynet"
local start = require "common.service.start"

local require_files = function()
end

start(function()
    require "server.game.rpc"
    skynet.timeout(0, require_files)
end)
