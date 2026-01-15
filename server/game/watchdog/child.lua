local mode, watchdog = ...
local require = require
local skynet = require "skynet"

if mode == "child" then
    local string = string
    local socket = require "skynet.socket"
    local proto = require "common.func.proto"
    local host = proto.host

    local close = function(fd)
        skynet.send(watchdog, "lua", "close_conn", fd)
    end

    local handle = {
        verify = function(args, _, fd)
            local verify = args.verify
            local acc = verify[1]
            if not acc then
                return
            end
            local key = skynet.call(watchdog, "lua", "get_key", acc)
            if not key then
                return
            end
            skynet.send(watchdog, "lua", "fd_acc", fd, acc)
            return {
                code = 0
            }
        end,
        choose_player = function(args, acc, fd)
            if not acc then
                return
            end
            local playerid = args.playerid
            if not playerid then
                return
            end
            skynet.call(watchdog, "lua", "choose_player", fd, acc, playerid)
            return {
                code = 0
            }
        end
    }

    local req = function(fd, msg, acc)
        local t, name, args, res = host:dispatch(msg)
        if not name then
            return
        end
        local func = handle[name]
        local ret = func(args, acc, fd)
        if not ret then
            return
        end
        socket.write(fd, string.pack(">s2", res(ret)))
        return true
    end

    skynet.start(function()
        skynet.dispatch("lua", function(_, _, fd, msg, acc)
            local ret = req(fd, msg, acc)
            if not ret then
                close(fd)
            end
            skynet.retpack()
        end)
    end)
else
    local watchdog = skynet.self()
    local childnum = 3
    local addrs = {}

    local M = {}

    local watchdog = skynet.self()
    for i = 1, childnum do
        local addr = skynet.newservice("server/game/watchdog/child", "child", watchdog)
        table.insert(addrs, addr)
    end

    M.data = function(fd, msg, acc)
        local idx = fd % childnum + 1
        local addr = addrs[idx]
        skynet.send(addr, "lua", fd, msg, acc)
    end

    return M
end
