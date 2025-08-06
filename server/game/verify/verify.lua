local require, string, print, type = require, string, print, type
local skynet = require "skynet"
local socket = require "skynet.socket"
local crypt = require "skynet.crypt"
local game_common = require "server.game.game_common"
local config_load = require "common.service.config_load"
local cmds = require "common.service.cmds"

local proto = config_load.proto()
local host = proto.host

local acc_key = {}
local acc_fd = {}
local close_fd = function(fd)
    skynet.send("watchdog", "lua", "close_conn", fd)
end

local save_fd = function(acc, fd)
    skynet.send("watchdog", "lua", "fd_acc", fd, acc)
    acc_fd[acc] = fd
end

local clear_acc = function(acc)
    acc_key[acc] = nil
    acc_fd[acc] = nil
end

local verify = function(acc, verify)
    if skynet.getenv("local_server") then
        return true
    end

    local key = acc_key[acc]
    if not key then
        return
    end

    if type(verify) ~= "table" then
        return
    end
    local v, pv = verify[1], verify[2]
    if not v or not pv then
        return
    end
    if v ~= crypt.desdecode(key, pv) then
        return
    end

    return true
end

local req = {
    verify = function(acc, args, fd, gate)
        if not verify(acc, args.verify) then
            return
        end
        save_fd(acc, fd)
        return {
            code = 0
        }
    end,
    select_player = function(acc, args, fd, gate)
        local acc, playerid = args.acc, args.playerid
        game_common.call_player_service("player_enter", playerid, fd, gate, acc)
        return {
            code = 0
        }
    end
}

cmds.data = function(acc, fd, msg, gate)
    local _, name, args, res = host:dispatch(msg)

    if name ~= "verify" then
        if acc_fd[acc] ~= fd then
            close_fd(fd)
            return
        end
    end
    local func = req[name]
    if not func then
        print("watchdog illegal req", name)
        close_fd(fd)
        return
    end
    local ret = func(acc, args, fd, gate)
    if ret then
        socket.write(fd, string.pack(">s2", res(ret)))
        return
    else
        close_fd(fd)
        return
    end
end

cmds.acc_offline = function(acc)
    print("verify acc_offline", acc)
    local fd = acc_fd[acc]
    if fd then
        close_fd(fd)
    end
    clear_acc(acc)
end

cmds.close = function(acc)
    print("verify close ...", acc)
    clear_acc(acc)
end

cmds.set_loginkey = function(acc, key)
    print("verify set key", acc)
    acc_key[acc] = key
end
