local skynet = require "skynet"
local start = require "server.service.service"

start(function()
    skynet.sleep(100)
    require "server.game.game.mgr"
    require "server.game.game.rpc"
end, "game")
