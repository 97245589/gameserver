local require = require
local skynet = require "skynet"
local socket = require "skynet.socket"
local proto = require "common.func.proto"
local req = require "server.game.player.req"
local player_mgr = require "server.game.player.player_mgr"

local spack = string.pack

local M = {}
local fd_playerid = {}
local playerid_fd = {}

local host = proto.host

local send_package = function(fd, pack)
    local ret = socket.write(fd, spack(">s2", pack))
    if not ret then
    end
end

local request = function(fd, cmd, args, res)
    local playerid = fd_playerid[fd]
    if not playerid then
        skynet.send("watchdog", "lua", "close_conn", fd)
    end

    local player = player_mgr.get_player(playerid)
    local func = req[cmd]
    local ret = func(player, args) or {
        code = -1
    }
    return res(ret)
end

M.player_enter = function()

end

skynet.register_protocol({
    name = "client",
    id = skynet.PTYPE_CLIENT,
    unpack = function(msg, sz)
        return host:dispatch(msg, sz)
    end,
    dispatch = function(fd, _, type, cmd, ...)
        send_package(fd, request(fd, cmd, ...))
    end
})

return M
