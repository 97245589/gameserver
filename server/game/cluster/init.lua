local skynet = require "skynet"
local start = require "server.service.service"

start(function()
    local gametype = tonumber(skynet.getenv("gametype"))
    if gametype == 1 then
        return
    end

    local cmd = require "server.func.cmd"
    require "server.service.cluster"
end)
