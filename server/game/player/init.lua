local start = require "server.service.service"
local name = ...

start(function()
    require "server.game.player.cmd"
end, name)
