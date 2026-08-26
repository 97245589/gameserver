local skynet = require "skynet"
local socket = require "skynet.socket"
local proto = require "server.func.proto"
local service = require "server.game.service"

local host = proto.host

local M = {}

local switch = {
    verify = function(args, fd)
        skynet.call("watchdog", "lua", "verify_success", fd, args.acc)
        return { code = 1 }
    end,
    select_character = function(args, fd, acc, gate)
        local cid = args.characterid
        service.call_id("character", "character_enter", cid, acc, fd, gate)
        return { code = 1 }
    end
}

M.watchdog_data = function(fd, msg, acc, gate)
    local _, cmd, args, resf = host:dispatch(msg)
    -- print("watchdog data", fd, cmd, dump(args))
    local f = switch[cmd]
    local ret = f(args, fd, acc, gate)
    if not ret then
        skynet.send("watchdog", "lua", "close_conn", fd)
        return
    end
    socket.write(fd, string.pack(">s2", resf(ret)))
end

return M
