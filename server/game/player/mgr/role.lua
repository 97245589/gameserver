local mgrs = require "server.game.player.mgrs"

local M = {}

M.init = function(player)
    player.role = player.role or {}
end

mgrs.add_mgr(M, "role")
return M
