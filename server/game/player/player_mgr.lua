local require = require
local print = print
local os = os
local skynet = require "skynet"
local mgrs = require "server.game.player.mgr.mgrs"
local zstd = require "common.func.zstd"

local M = {}

local players = {}
M.players = players

local player_db = function(playerid)
    -- local bin = db.call("hmget", "pl:" .. playerid, "info")
    if players[playerid] then
        return players[playerid]
    end
    -- local player = zstd.decode(bin) 
    local player = {}
    mgrs.all_init(player)
    players[playerid] = player
    return player
end

M.get_player = function(playerid)
    local player = players[playerid] or player_db(playerid)
    if not player then
        return
    end
    player.playerid = playerid
    player.gettm = os.time()
    return player
end

return M
