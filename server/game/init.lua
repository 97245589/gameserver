local skynet = require "skynet"

local service_cfg = {
    game = 5,
    watchdog = 1
}

skynet.start(function()
    skynet.newservice("server/game/watchdog/init")
    for i = 1, 10 do
        skynet.newservice("server/game/player/init")
    end
end)
