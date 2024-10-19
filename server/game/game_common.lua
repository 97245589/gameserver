local require = require
local skynet = require "skynet"
local config = require "common.service.service_config"
local crc = require "common.tool.crc"

local M = {}

local crc32 = crc.crc32
local player_service_num = config.service_num.game_player_service
local playerserviceid = function(playerid)
    local num = crc32(playerid)
    return num % player_service_num + 1
end

M.send_player_service = function(cmd, playerid, ...)
    local player_service = playerserviceid(playerid)
    skynet.send("player" .. player_service, "lua", cmd, playerid, ...)
end

M.call_player_service = function(cmd, playerid, ...)
    local player_service = playerserviceid(playerid)
    return skynet.call("player" .. player_service, "lua", cmd, playerid, ...)
end

M.send_all_player_service = function(...)
    for i = 1, player_service_num do
        skynet.send("player" .. i, "lua", ...)
    end
end

return M
