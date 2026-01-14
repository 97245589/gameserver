local require = require
local print = print
local skynet = require "skynet"
local proto = require "common.func.proto"
local cmds = require "common.service.cmds"

local gate = skynet.newservice("gate")
skynet.call(gate, "lua", "open", {
    port = skynet.getenv("gate_port"),
    maxclient = 8888,
    nodelay = true
})

local host = proto.host
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

cmds.close_conn = close_conn

local reqhandle = {
    verify = function()
    end,
    choose_player = function()
    end
}
local req = function(fd, msg)
    local t, name, args, res = host:dispatch(msg)
    if not name then
        close_conn(fd)
        return
    end
end

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
    data = req
}
cmds.socket = function(cmd, ...)
    local func = socket_cmds[cmd]
    if func then
        func(...)
    else
        print("watchdog socket cmds err", cmd)
    end
end
