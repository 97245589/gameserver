local start = require "server.service.service"

start(function()
    require "server.game.watchdog.watchdog"
end, "watchdog")
