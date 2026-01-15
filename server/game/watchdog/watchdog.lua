local require = require
local print = print
local skynet = require "skynet"
local cmds = require "common.service.cmds"
local child = require "server.game.watchdog.child"
local rpc = require "server.game.rpc"

local gate = skynet.newservice("gate")
skynet.call(gate, "lua", "open", {
    port = skynet.getenv("gate_port"),
    maxclient = 8888,
    nodelay = true
})

local acc_key = {}
local acc_fd = {}
local fd_acc = {}
local close_conn = function(fd)
    local acc = fd_acc[fd]
    if acc then
        acc_key[acc] = nil
        acc_fd[acc] = nil
        fd_acc[fd] = nil
    end
    skynet.send(gate, "lua", "kick", fd)
end

cmds.acc_key = function(acc, key)
    acc_key[acc] = key
end

cmds.get_key = function(acc)
    return acc_key[acc]
end

cmds.fd_acc = function(fd, acc)
    local bfd = acc_fd[acc]
    if bfd then
        fd_acc[bfd] = nil
        skynet.send(gate, "lua", "kick", fd)
    end
    acc_fd[acc] = fd
    fd_acc[fd] = acc
end

cmds.choose_player = function(fd, acc, playerid)
    rpc.rpc_send_id("player", "player_enter", playerid, acc, gate)
end

cmds.close_conn = close_conn

local socket_cmds = {
    open = function(fd, addr)
        skynet.send(gate, "lua", "accept", fd)
    end,
    close = function(fd)
        close_conn(fd)
    end,
    error = function(fd, msg)
        print("socket error", fd, msg)
        close_conn(fd)
    end,
    warning = function(fd, size)
        print("socket warning", fd, size)
    end,
    data = function(fd, msg)
        local acc = fd_acc[fd]
        child.data(fd, msg, acc)
    end
}
cmds.socket = function(cmd, ...)
    local func = socket_cmds[cmd]
    if func then
        func(...)
    end
end
