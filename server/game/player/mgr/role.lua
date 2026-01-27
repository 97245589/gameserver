local mgrs = require "server.game.player.mgr.mgrs"

local M = {}

M.init = function(player)
    player.role = player.role or {}
    local role = player.role
    role.playerid = role.playerid
    role.acc = role.acc
    role.level = role.level or 0
end

mgrs.add_mgr(M, "role")
return M
