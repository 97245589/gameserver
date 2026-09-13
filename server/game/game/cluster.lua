local skynet = require "skynet"

local gametype = tonumber(skynet.getenv("gametype"))
if gametype == 1 then
    return
end

local sc = require "server.service.cluster"
