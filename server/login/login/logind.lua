local require, print, table, ipairs = require, print, table, ipairs
local skynet = require "skynet"
local socket = require "skynet.socket"
local crc = require "skynet.db.redis.crc16"
local cmds = require "common.service.cmds"

local addrs = {}
local instance = 2
for i = 1, instance do
    local addr = skynet.newservice("server/login/login/dispatch", "child")
    table.insert(addrs, addr)
end

local id = socket.listen("0.0.0.0", skynet.getenv("gate_port"))
socket.start(id, function(fd, addr)
    print("logind accept from", addr, fd)
    local s = addrs[crc(addr) % instance + 1]
    skynet.send(s, "lua", "login", fd, addr)
end)

local handle_addrs = {}
local handle_num = 2
for i = 1, instance do
    local addr = skynet.newservice("server/login/login/handle", "child")
    table.insert(handle_addrs, addr)
end
for _, addr in ipairs(addrs) do
    skynet.send(addr, "lua", "handle_addrs", handle_addrs)
end

cmds.game_servers = function(args)
    for _, addr in ipairs(handle_addrs) do
        skynet.send(addr, "lua", "game_servers", args)
    end
end
