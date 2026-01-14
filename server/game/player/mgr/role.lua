local mgrs = require "server.game.player.mgrs"

local M = {}

M.cfg = function()
    
end

M.init = function(player)
    player.role = player.role or {}
end

M.tick = function(player)
    local role = player.role
end

mgrs.add_mgr(M, "role")
return M
