local require = require
local skynet = require "skynet"
local start = require "common.service.start"

start(function()
    require "server.game.rpc"
    local lserver = skynet.getenv("local_server")
    if lserver then
        return
    end

    skynet.timeout(100, function()
        require "common.service.cluster"
    end)
end)
