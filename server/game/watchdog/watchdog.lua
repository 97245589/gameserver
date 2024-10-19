local require, print, string, math = require, print, string, math
local random = math.random
local skynet = require "skynet"
local cluster = require "skynet.cluster"
local socket = require "skynet.socket"
local crypt = require "skynet.crypt"
local cmds = require "common.service.cmds"
local common = require "server.game.game_common"
local service_config = require "common.service.service_config"

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

socket_cmd.data = function(fd, msg)
    local num = service_config.service_num.game_player_service
    local i = random(num)
    skynet.send("player" .. i, "lua", "select_player", fd, msg, gate)
end
