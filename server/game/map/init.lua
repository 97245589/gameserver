local map = require "server.game.common.mapser"
local cmd = require "server.func.cmd"

map.start(function()
end)

map.set_map_impl(100, {
    actor_die = function()
    end
})
