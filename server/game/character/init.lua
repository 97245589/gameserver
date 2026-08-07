local start = require "server.service.service"
local name = ...

start(function()
    require "server.game.character.req"
    require "server.game.character.rpc"
end, name)
