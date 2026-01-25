local require = require
local os = os
local pairs = pairs
local table = table
local next = next
local skynet = require "skynet"
local mgrs = require "server.game.player.mgrs"
local zstd = require "common.func.zstd"

local M = {}

local players = {}
M.players = players

local get_player_from_db = function(playerid)
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
    local player = players[playerid] or get_player_from_db
    if not player then
        return
    end
    player.playerid = playerid
    player.gettm = os.time()
    return player
end

local playerids = {}
local save_kick = function(tm)
    if not next(playerids) then
        for playerid in pairs(players) do
            table.insert(playerid)
        end
    end

    for i = 1, 3 do
        if not next(playerids) then
            return
        end
        local playerid = table.remove(playerids)
        local player = players[playerid]
        -- db.send("hmset", "pl:"..playerid, "info", zstd.encode(player))
        if tm > player.gettm + 60 then
            players[playerid] = nil
            M.kick_player(playerid)
        end
    end
end

skynet.fork(function()
    while true do
        skynet.sleep(100)
        local tm = os.time()
        save_kick(tm)
        for playerid, player in pairs(players) do
            mgrs.all_tick(player, tm)
        end
    end
end)

return M
