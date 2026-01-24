local mgrs = require "server.game.player.mgrs"
local cfg = require "common.func.cfg"

local M = {}

M.cfg = function()
    local item = cfg.get("item")
end

M.init = function(player)
    player.role = player.role or {}
end

mgrs.add_mgr(M, "role")
return M
