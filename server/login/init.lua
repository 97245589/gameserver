local start = require "server.service.service"
local skynet = require "skynet"

start(function()
    local sc = require "server.service.cluster"
    skynet.newservice("server/login/login")
end, "init")
