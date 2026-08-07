local skynet = require "skynet"
local cmd = require "server.func.cmd"
local child = require "server.game.watchdog.child"

local gate = skynet.newservice("gate")
skynet.call(gate, "lua", "open", {
    port = skynet.getenv("gate_port"),
    maxclient = 6666,
    nodelay = true
})
child.start(2, gate)

local acc_secret = {}
local acc_fd = {}
local fd_acc = {}
local close_conn = function(fd)
    local acc = fd_acc[fd]
    if acc then
        acc_secret[acc] = nil
        acc_fd[acc] = nil
        fd_acc[fd] = nil
    end
    print("close conn", fd, acc)
    skynet.send(gate, "lua", "kick", fd)
end
cmd.close_conn = close_conn

cmd.verify_success = function(fd, acc)
    -- print("verify success", fd, acc)
    local bfd = acc_fd[acc]
    if bfd then
        fd_acc[bfd] = nil
        skynet.send(gate, "lua", "kick", fd)
    end
    acc_fd[acc] = fd
    fd_acc[fd] = acc
end

local scmd = {
    open = function(fd, addr)
        skynet.send(gate, "lua", "accept", fd)
    end,
    close = function(fd)
        close_conn(fd)
    end,
    error = function(fd, msg)
        close_conn(fd)
    end,
    warning = function(fd, size)
        print("socket warning", fd, size)
        close_conn(fd)
    end,
    data = function(fd, msg)
        local acc = fd_acc[fd]
        child.data(fd, msg, acc)
    end
}
cmd.socket = function(c, ...)
    local f = scmd[c]
    if f then
        f(...)
    end
end

-- loginserver
cmd.acc_secret = function(acc, secret)
    acc_secret[acc] = secret
end

cmd.kick_acc = function(acc)
    local fd = acc_fd[acc]
    if fd then
        close_conn(fd)
    end
end

cmd.get_secret = function(acc)
    return acc_secret[acc]
end
-- loginserver
