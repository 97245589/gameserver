local mode = ...
if mode ~= "child" then
    return
end

local require, string, print = require, string, print
local skynet = require "skynet"
local socket = require "skynet.socket"
local crypt = require "skynet.crypt"
local game_common = require "server.game.game_common"

local config_load = require "common.service.config_load"
local proto = config_load.proto()
local host = proto.host
local spack = string.pack

local LOGIN_KEY
local verify = function(acc, token)
    if skynet.getenv("local_server") then
        return true
    end
    if not acc or not token then
        return
    end

    local str = crypt.desdecode(LOGIN_KEY, token)
    local arr = skynet.unpack(str)
    local tacc, tt = arr[1], arr[2]
    if tacc ~= acc then
        return
    end
    return true
end

local close_fd = function(fd)
    skynet.send("watchdog", "lua", "close_conn", fd)
end

local req = {
    select_player = function(args, fd, gate)
        local acc, playerid = args.acc, args.playerid
        game_common.call_player_service("player_enter", playerid, fd, gate, acc)
        return {
            code = 0
        }
    end
}

local cmds = {
    set_login_key = function(key)
        LOGIN_KEY = key
    end,
    data = function(fd, msg, gate)
        local type, name, args, res = host:dispatch(msg)
        local acc, token = args.acc, args.token
        if not verify(acc, token) or not name then
            close_fd(fd)
            return
        end
        local func = req[name]
        if not func then
            print("watchdog illegal req", name)
            close_fd(fd)
            return
        end
        local ret = func(args, fd, gate)
        if ret then
            socket.write(fd, spack(">s2", res(ret)))
            return
        else
            close_fd(fd)
            return
        end
    end
}

skynet.start(function()
    skynet.dispatch("lua", function(_, _, cmd, ...)
        local func = cmds[cmd]
        if func then
            skynet.retpack(func(...))
        else
            skynet.response()(false)
        end
    end)
end)
