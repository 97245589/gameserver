local require, string, print = require, string, print
local skynet = require "skynet"

local table, ipairs = table, ipairs
local cmds = require "common.service.cmds"

local instance = 2
local childs = {}
for i = 1, instance do
    local addr = skynet.newservice("server/game/watchdog/handle", "child")
    table.insert(childs, addr)
end

local data_handle = function(fd, msg, gate)
    local i = fd % instance + 1
    skynet.send(childs[i], "lua", "data", fd, msg, gate)
end

local set_login_key = function(key)
    for _, addr in ipairs(childs) do
        skynet.send(addr, "lua", "set_login_key", key)
    end
end
cmds.set_login_key = set_login_key

local watchdog = require "common.service.watchdog"
watchdog.set_data_handle(data_handle)

