local mode, watchdog = ...

if mode == "child" then
    local require, pcall = require, pcall
    local skynet = require "skynet"
    local gamecommon = require "server.game.game_common"
    local proto = require"common.service.config_load".proto()
    local host = proto.host

    local close_conn = function(fd)
        skynet.send(watchdog, "lua", "close_conn", fd)
    end

    local func = function(msg, fd, gate)
        local ok, acc = pcall(function()
            local _, _, req = host:dispatch(msg)
            return req.acc
        end)
        if not ok or not acc then
            close_conn(fd)
            return
        end

        gamecommon.send_verify_service("data", acc, fd, msg, gate)
    end

    skynet.start(function()
        skynet.dispatch("lua", function(_, _, msg, fd, gate)
            func(msg, fd, gate)
            skynet.response()(false)
        end)
    end)
else
    local require, table = require, table
    local print, dump = print, dump
    local skynet = require "skynet"
    local cmds = require "common.service.cmds"
    local proto = require"common.service.config_load".proto()
    local gamecommon = require "server.game.game_common"

    local child_num = 2
    local addrs = {}
    for i = 1, child_num do
        local addr = skynet.newservice("server/game/watchdog/watchdog", "child", skynet.self())
        table.insert(addrs, addr)
    end

    local host = proto.host
    local fd_acc = {}

    local gate = skynet.newservice("gate")
    skynet.call(gate, "lua", "open", {
        port = skynet.getenv("gate_port"),
        maxclient = 8888,
        nodelay = true
    })

    local close_conn = function(fd)
        print("watchdog close_conn", fd)
        fd_acc[fd] = nil
        skynet.send(gate, "lua", "kick", fd)
    end

    local socket_cmd = {
        open = function(fd, addr)
            skynet.send(gate, "lua", "accept", fd)
        end,
        close = function(fd)
            local acc = fd_acc[fd]
            if acc then
                gamecommon.send_verify_service("close", acc)
            end
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
            local addr = addrs[fd % child_num + 1]
            skynet.send(addr, "lua", msg, fd, gate)
        end

    }
    cmds.socket = function(sub_cmd, ...)
        local f = socket_cmd[sub_cmd]
        if f then
            f(...)
        end
    end

    cmds.close_conn = close_conn
    cmds.fd_acc = function(fd, acc)
        fd_acc[fd] = acc
    end
end

