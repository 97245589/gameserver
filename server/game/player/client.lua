local require = require
local skynet = require "skynet"
local cmds = require "common.service.cmds"
local proto = require "common.func.proto"
local player = require "server.game.player.player_mgr"

local M = {}
local fd_playerid = {}
local playerid_fd = {}

local host = proto.host

local send_package = function(fd, pack)

end

local request = function(fd, cmd, args, res)
    local playerid = fd_playerid[fd]
    if not playerid then
        skynet.send("watchdog", "lua", "close_conn", fd)
    end

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

    end
})

return M
