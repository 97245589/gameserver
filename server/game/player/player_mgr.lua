local require = require
local os = os
local skynet = require "skynet"
local redis = require "common.func.redis"
local mgrs = require "server.game.player.mgr.mgrs"

local M = {}

local players = {}
M.players = players

local get_player_from_db = function(playerid)
    if players[playerid] then
        return players[playerid]
    end
    local player = {}
    mgrs.all_init(player)
    players[playerid] = player
    return player
end

M.get_player = function(playerid)
    local player = players[playerid] or get_player_from_db
    if not player then
        return
    end
    player.playerid = playerid
    return player
end

skynet.fork(function ()
    while true do
        skynet.sleep(100)
        for playerid, player in pairs(players) do
            mgrs.all_tick(player, os.time())
        end
    end
end)

return M
