local start = require "server.service.service"
local skynet = require "skynet"

start(function()
    require "server.service.cluster"
    skynet.newservice("server/db/mgr")
end, "init")
