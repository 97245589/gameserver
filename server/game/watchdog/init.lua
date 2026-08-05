local start = require "server.service.service"
local name = ...

start(function()
    require "server.game.watchdog.watchdog"
end, name)
