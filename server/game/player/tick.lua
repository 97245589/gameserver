local require, os, print, pcall = require, os, print, pcall
local next, pairs = next, pairs
local skynet = require "skynet"
local zstd = require "common.tool.zstd"
local db = require "common.service.db"
local mgrs = require "server.game.player.mgrs"

local profile = require "skynet.profile"
local profile_info = require "common.service.profile"

local client_req = require "server.game.player.client_req"
local kick_player = client_req.kick_player
local players = require "server.game.player.players"
local online_players = players.online_players

local OFFLINE_TM = 10
local TICK_SAVE_NUM = 5

local gen_ids = function(ids, obj)
    if next(ids) then
        return ids
    end
    local ret = {}
    for k, _ in pairs(obj) do
        ret[k] = 1
    end
    return ret
end

local offline_player = function(player, playerid)
    print("save player ...", playerid, zstd.encode(player))
    if os.time() > player.role.heartbeat + OFFLINE_TM then
        client_req.kick_player(playerid)
        online_players[playerid] = nil
    end
end

local playerids = {}
local tick_save_player = function()
    playerids = gen_ids(playerids, online_players, 1)
    local i = 1
    for playerid, _ in pairs(playerids) do
        -- print("tick_save_player", os.time(), playerid)
        local player = online_players[playerid]
        offline_player(player, playerid)
        playerids[playerid] = nil
        i = i + 1
        if i > TICK_SAVE_NUM then
            return
        end
    end
end

local tick_save = function()
    profile.start()

    tick_save_player()

    local time = profile.stop()
    local cmd_name = "tick_save_player"
    profile_info.add_cmd_profile(cmd_name, time)
end

skynet.fork(function()
    local TICK_TIME = 100
    while true do
        skynet.sleep(TICK_TIME)
        mgrs.all_tick()
        tick_save()
        for playerid, player in pairs(online_players) do
            mgrs.all_tick_player(player)
        end
    end
end)
