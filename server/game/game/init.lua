local skynet = require "skynet"
local start = require "server.service.service"

start(function()
    require "server.game.game.rpc"
    require "server.game.game.mod.gevent"
    require "server.game.game.mod.map"
    require "server.game.game.cluster"
end, "game")
