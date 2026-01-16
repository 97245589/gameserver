local mgrs = require "server.game.player.mgrs"
local cfg = require "common.func.cfg"

local M = {}

M.cfg = function()
    local item = cfg.get("item")
end

M.init = function(player)
    player.role = player.role or {}
end

M.tick = function(player)
    local role = player.role
end

mgrs.add_mgr(M, "role")
return M
