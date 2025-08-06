local mode = ...
if mode ~= "child" then
    return
end

local require, string, tonumber = require, string, tonumber
require "common.tool.lua_tool"
local print, split, dump = print, split, dump

local skynet = require "skynet"
local socket = require "skynet.socket"
local crypt = require "skynet.crypt"
local crc = require "skynet.db.redis.crc16"
local zstd = require "common.tool.zstd"

local handle_addrs, handle_num
local config_load = require "common.service.config_load"
local proto = config_load.proto()
local host = proto.host

local send_package = function(fd, pack)
    local package = string.pack(">s2", pack)
    socket.write(fd, package)
end

local get_req = function(fd)
    local len = socket.read(fd, 2)
    len = len:byte(1) * 256 + len:byte(2)
    local msg = socket.read(fd, len)
    return host:dispatch(msg)
end

local send_token = function(fd, key)
    local _, name, args, res = get_req(fd)
    local acc = args.acc
    if name ~= "login_token" or not acc then
        return
    end
    send_package(fd, res({
        code = 0,
        token = crypt.desencode(key, zstd.pack({acc}))
    }))
    return true
end

local verify = function(acc, token, key)
    local arr = zstd.unpack(crypt.desdecode(key, token))
    if acc ~= arr[1] then
        return
    end
    return true
end
local gameserver_key = function(fd, key)
    local _, name, args, res = get_req(fd)
    if name ~= "gamekey" then
        return
    end

    local acc = args.acc
    local token = args.token
    local server = args.server
    if not verify(acc, token, key) then
        return
    end

    local haddr = handle_addrs[crc(acc) % handle_num + 1]
    local ret = skynet.call(haddr, "lua", "login_req", acc, server)
    send_package(fd, res(ret))
    return true
end
local login = function(fd, addr)
    socket.start(fd)
    socket.limit(fd, 4096)
    local key = crypt.randomkey()
    if not send_token(fd, key) then
        socket.close(fd)
        return
    end
    if not gameserver_key(fd, key) then
        socket.close(fd)
        return
    end
    socket.close(fd)
end

local cmds = {
    login = login,
    handle_addrs = function(v)
        handle_addrs = v
        handle_num = #v
    end
}
skynet.start(function()
    skynet.dispatch("lua", function(_, _, cmd, ...)
        local func = cmds[cmd]
        if func then
            skynet.retpack(func(...))
        else
            skynet.response()(false)
        end
    end)
end)
