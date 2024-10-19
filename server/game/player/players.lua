local require = require
local skynet = require "skynet"
local mgrs = require "server.game.player.mgrs"
local db = require "common.service.db"
local zstd = require "common.tool.zstd"

local online_players = {}
local get_player_from_db = function(playerid)
    local player = {}
    if online_players[playerid] then
        return online_players[playerid]
    end
    mgrs.all_init_player(player)
    player.role.playerid = playerid
    online_players[playerid] = player
end

local M = {}

M.get_player = function(playerid)
    local player = online_players[playerid]
    if player then
        return player
    else
        return get_player_from_db(playerid)
    end
end

M.online_players = online_players

return M
