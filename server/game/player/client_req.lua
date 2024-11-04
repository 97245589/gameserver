local require, string, os, error = require, string, os, error
local print, split, tonumber = print, split, tonumber

local skynet = require "skynet"
local socket = require "skynet.socket"
local crypt = require "skynet.crypt"
local profile = require "skynet.profile"
local profile_info = require "common.service.profile"
local players = require "server.game.player.players"
local game_common = require "server.game.game_common"

local proto
local host
local push_req
local SERVICE_NAME = SERVICE_NAME
local LOGIN_KEY

local load_proto = function()
    local config_load = require "common.service.config_load"
    proto = config_load.proto()
    host = proto.host
    push_req = proto.push_req
end
load_proto()

local send_package = function(fd, pack)
    socket.write(fd, string.pack(">s2", pack))
end

local client_cmds = {}
local fd_playerid = {}
local playerid_fd = {}

local kick_player = function(playerid)
    local fd = playerid_fd[playerid]
    print(SERVICE_NAME, "kick_player", playerid, fd)
    if fd then
        playerid_fd[playerid] = nil
        fd_playerid[fd] = nil
        skynet.send("watchdog", "lua", "close_conn", fd)
    end
end

local player_enter = function(fd, gate, acc, playerid)
    print("player_enter", SERVICE_NAME, playerid)
    kick_player(playerid)
    skynet.send(gate, "lua", "forward", fd)
    fd_playerid[fd] = playerid
    playerid_fd[playerid] = fd
    local player = players.get_player(playerid)
end

local verify = function(acc, token, playerid)
    if skynet.getenv("local_server") then
        return true
    end
    if not acc or not token or not playerid then
        skynet.send("watchdog", "lua", "close_conn", fd)
        return
    end

    local str = crypt.desdecode(LOGIN_KEY, token)
    local arr = skynet.unpack(str)
    local tacc, tt = arr[1], arr[2]
    if tacc ~= acc then
        skynet.send("watchdog", "lua", "close_conn", fd)
        return
    end
    return true
end

local select_player = function(fd, msg, gate)
    print("select_player", SERVICE_NAME)
    local type, name, args, res = host:dispatch(msg)
    local acc, token, playerid = args.acc, args.token, args.playerid

    if not verify(acc, token, playerid) then
        skynet.send("watchdog", "lua", "close_conn", fd)
        return
    end

    local fplayerid = fd_playerid[fd]
    fd_playerid[fd] = nil
    if fplayerid then
        playerid_fd[fplayerid] = nil
    end
    game_common.send_player_service("player_enter", playerid, fd, gate, acc)
    send_package(fd, res {
        code = 0
    })
end

local login_key = function(login_key)
    LOGIN_KEY = login_key
end

local push = function(player, name, args)
    local str = push_req(name, args, 0)
    local fd = playerid_fd[player.role.playerid]
    send_package(fd, str)
end

local request = function(fd, cmd, args, res)
    local playerid = fd_playerid[fd]
    if not playerid then
        return skynet.send("watchdog", "lua", "close_conn", fd)
    end
    local player = players.get_player(playerid)
    player.role.heartbeat = os.time()
    local cli_func = client_cmds[cmd]
    local ret = cli_func(player, args) or {
        code = -1
    }
    return res(ret)
end

skynet.register_protocol({
    name = "client",
    id = skynet.PTYPE_CLIENT,
    unpack = function(msg, sz)
        return host:dispatch(msg, sz)
    end,
    dispatch = function(fd, _, type, cli_cmd, ...)
        skynet.ignoreret()
        profile.start()

        send_package(fd, request(fd, cli_cmd, ...))

        local time = profile.stop()
        local cmd_name = "clireq.." .. cli_cmd
        profile_info.add_cmd_profile(cmd_name, time)
    end
})

local M = {
    client_cmds = client_cmds,
    kick_player = kick_player,
    player_enter = player_enter,
    select_player = select_player,
    login_key = login_key,
    push = push,
    load_proto = load_proto
}

return M
