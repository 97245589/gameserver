local skynet = require "skynet"
local crypt = require "skynet.crypt"
local socket = require "skynet.socket"
local proto = require "server.func.proto"
local service = require "server.game.service"

local host = proto.host

local M = {}

local switch = {
    verify = function(args, fd)
        return { code = 1 }
    end,
    select_character = function(args, fd, acc, gate)
        local cid = args.characterid
        service.call_id("character", "character_enter", cid, acc, fd, gate)
        return { code = 1 }
    end
}

local gametype = tonumber(skynet.getenv("gametype"))
local verify = function(args)
    local acc = args.acc
    local token = args.token
    if not acc then
        return
    end
    if gametype == 1 then
        return acc
    end
    local secret = skynet.call("watchdog", "lua", "get_secret", acc)
    if token ~= crypt.desencode(secret, acc) then
        return
    end
    return acc
end

local close_conn = function(fd)
    skynet.send("watchdog", "lua", "close_conn", fd)
end

M.watchdog_data = function(fd, msg, acc, gate)
    local _, cmd, args, resf = host:dispatch(msg)
    if not acc then
        acc = verify(args)
        if not acc then
            close_conn(fd)
            return
        else
            -- print("verify succ", fd, acc)
            skynet.send("watchdog", "lua", "verify_success", fd, acc)
        end
    end

    local f = switch[cmd]
    local ret = f(args, fd, acc, gate)
    if not ret then
        close_conn(fd)
        return
    end
    socket.write(fd, string.pack(">s2", resf(ret)))
end

return M
