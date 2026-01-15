local mgrs = require "server.game.player.mgr.mgrs"
local cfg = require "common.func.cfg"

local M = {}

M.cfg = function()
    local item = cfg.load_cfg("item")
end

M.init = function(player)
    player.role = player.role or {}
end

M.tick = function(player)
    local role = player.role
end

mgrs.add_mgr(M, "role")
return M
