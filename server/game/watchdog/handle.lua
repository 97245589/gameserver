local mode = ...
if mode ~= "child" then
    return
end

require "common.tool.lua_tool"
local require, string, print = require, string, print
local skynet = require "skynet"
require "skynet.manager"
local socket = require "skynet.socket"
local crypt = require "skynet.crypt"
local game_common = require "server.game.game_common"
local config_load = require "common.service.config_load"
local zstd = require "common.tool.zstd"

skynet.register("watchdogh")
local proto = config_load.proto()
local host = proto.host
local spack = string.pack

local acc_key = {}
local acc_fd = {}
local fd_acc = {}
local LOGIN_KEY
local verify = function(name, acc, token)
    local key
    if name == "verify" then
        if skynet.getenv("local_server") then
            return true
        end
        key = LOGIN_KEY
    else
        key = acc_key[acc]
    end
    print("verify", name, acc, key, LOGIN_KEY)

    if not key then
        return
    end
    print("verify", name, acc)
    local arr = zstd.unpack(crypt.desdecode(key, token))
    local tacc, tt = arr[1], arr[2]
    if tacc ~= acc then
        return
    end
    if name == "verify" then
        print("verify ========", tt, skynet.time())
        if tt + 60 < skynet.time() then
            return
        end
    end
    return true
end

local req = {
    verify = function(args, fd)
        local acc = args.acc
        local key = crypt.randomkey()
        acc_key[acc] = key
        acc_fd[acc] = fd
        fd_acc[fd] = acc
        return {
            code = 0,
            token = crypt.desencode(key, zstd.pack({acc, skynet.time()}))
        }
    end,
    select_player = function(args, fd, gate)
        local acc, playerid = args.acc, args.playerid
        game_common.call_player_service("player_enter", playerid, fd, gate, acc)
        return {
            code = 0
        }
    end
}

local close_fd = function(fd)
    skynet.send("watchdog", "lua", "close_conn", fd)
end
local cmds = {
    set_login_key = function(key)
        LOGIN_KEY = key
    end,
    data = function(fd, msg, gate)
        local type, name, args, res = host:dispatch(msg)
        local acc, token = args.acc, args.token
        if not name or not acc or not token then
            close_fd(fd)
            return
        end
        if not verify(name, acc, token) then
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
    end,
    acc_offline = function(acc)
        local fd = acc_fd[acc]
        if fd then
            fd_acc[fd] = nil
            close_fd(fd)
        end
        acc_fd[acc] = nil
        acc_key[acc] = nil
    end,
    close = function(fd)
        -- print("watchdogh close", fd)
        local acc = fd_acc[fd]
        fd_acc[fd] = nil
        if acc then
            acc_key[acc] = nil
            acc_fd[acc] = nil
        end
    end
}

skynet.start(function()
    skynet.dispatch("lua", function(_, _, cmd, ...)
        -- local mqlen = skynet.stat("mqlen")

        local func = cmds[cmd]
        if func then
            skynet.retpack(func(...))
        else
            skynet.response()(false)
        end
    end)
end)
