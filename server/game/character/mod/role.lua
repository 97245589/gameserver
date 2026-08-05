local M = {}

M.init = function(player)
    player.role = player.role or {}
    local role = player.role
    role.level = role.level or 1
end

local mod = require "server.game.player.mod"
mod.add_module(M, "role")
return M
