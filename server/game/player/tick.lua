local require = require
local skynet = require "skynet"
local player_mgr = require "server.game.player.player_mgr"

local tick = function()

end

skynet.fork(function()
    while true do
        skynet.sleep(100)
        tick(os.time())
    end
end)
