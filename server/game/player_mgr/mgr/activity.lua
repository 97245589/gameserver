local require = require
local player_mgr = require "server.game.player_mgr.player_mgr"
local db_data = player_mgr.db_data
if not db_data.activity then
    db_data.activity = {}
end

local db_activity = db_data.activity

local M = {}

M.tick = function()
end

local mgrs = require "server.game.player_mgr.mgrs"
mgrs.add_mgr("activity", M)
return M
