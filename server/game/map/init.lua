local start = require "server.service.service"

start(function()
    require "server.game.map.mgr"
end)
