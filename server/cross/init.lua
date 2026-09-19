local skynet = require "skynet"
local cluster = require "skynet.cluster"
local start = require "server.service.service"
local mapmgr = require "server.game.game.mod.mapmgr"

local server_mark = skynet.getenv("server_mark")
start(function()
    local sc = require "server.service.cluster"
    
    mapmgr.init(3)
    mapmgr.add(1, 88)
end)
