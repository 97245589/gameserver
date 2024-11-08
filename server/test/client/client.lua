local require, string, print, pairs, os = require, string, print, pairs, os
require "common.tool.lua_tool"
local print_v, dump = print_v, dump
local skynet = require "skynet"
local crypt = require "skynet.crypt"
local socket = require "skynet.socket"

local acc, playerid = ...
acc = acc or "1993"
playerid = playerid or 1993
-- print("------ acc playerid", acc, playerid)

local config_load = require "common.service.config_load"
local proto = config_load.proto()
local host = proto.host
local request = proto.push_req

local fd
local session = 1
local gameid = 1
local game_token
local game_host
local send_request
local recv_data

local get_game_token = function()
    local service_config = require "common.service.service_config"
    fd = socket.open("0.0.0.0", 10301)
    print("-------", fd)
    send_request("login_req", {
        acc = acc,
        server = 1,
        token = crypt.desencode(service_config.login_service_key, acc .. "|" .. os.time())
    })

    local res, session, res_data = recv_data()
    print(res, session, dump(res_data))
    game_token, game_host = res_data.token, res_data.host
    fd = nil
end

local conn_to_server = function()
    game_host = game_host or "0.0.0.0:10101"
    fd = socket.open(game_host)
end

local send_package = function(fd, pack)
    local package = string.pack(">s2", pack)
    socket.write(fd, package)
end

recv_data = function()
    local len
    len = socket.read(fd, 2)
    len = len:byte(1) * 256 + len:byte(2)
    local msg = socket.read(fd, len)
    return host:dispatch(msg)
end

send_request = function(name, args)
    session = session + 1
    local str = request(name, args, session)
    send_package(fd, str)
end

local init_func = function()
    get_game_token()

    conn_to_server()

    send_request("select_player", {
        acc = acc,
        token = game_token or "",
        playerid = playerid
    })
    print("select_player", recv_data())

    skynet.fork(function()
        while true do
            print(recv_data())
        end
    end)

    skynet.fork(function()
        while true do
            skynet.sleep(100)
            send_request("push_test", {})
        end
    end)
end

skynet.start(function()
    init_func()
end)
