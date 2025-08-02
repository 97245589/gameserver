local require, print, string, math = require, print, string, math
local skynet = require "skynet"
local cmds = require "common.service.cmds"

local gate = skynet.newservice("gate")
skynet.call(gate, "lua", "open", {
    port = skynet.getenv("gate_port"),
    maxclient = 8888,
    nodelay = true
})

local close_conn = function(fd)
    print("watchdog close_conn", fd)
    skynet.send(gate, "lua", "kick", fd)
end

cmds.close_conn = close_conn

local socket_cmd = {}

cmds.socket = function(sub_cmd, ...)
    local f = socket_cmd[sub_cmd]
    if f then
        f(...)
    end
end

socket_cmd.open = function(fd, addr)
    -- print("watchdog accept", fd, addr)
    skynet.send(gate, "lua", "accept", fd)
end

socket_cmd.close = function(fd)
    close_conn(fd)
end

socket_cmd.error = function(fd, msg)
    print("socket error", fd, msg)
    close_conn(fd)
end

socket_cmd.warning = function(fd, size)
    print("socket warning", fd, size)
end

local data_handle
socket_cmd.data = function(fd, msg)
    if data_handle then
        data_handle(fd, msg, gate)
    else
        close_conn(fd)
    end
end

return {
    set_data_handle = function(func)
        data_handle = func
    end
}
