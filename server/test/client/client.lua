local require, string, print, pairs, os = require, string, print, pairs, os
require "common.tool.lua_tool"
local print_v, dump = print_v, dump
local skynet = require "skynet"
local crypt = require "skynet.crypt"
local socket = require "skynet.socket"

local acc, playerid, local_server = ...
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

local login = function()
    fd = socket.open("0.0.0.0", 10301)

    send_request("login_key", {
        acc = acc
    })
    local _, _, res = recv_data()
    print("get login key", dump(res))
    local key = res.key

    local token = crypt.desencode(key, acc .. "|" .. gameid)
    send_request("gamekey", {
        acc = acc,
        server = gameid,
        token = token
    })

    local _, _, res_data = recv_data()
    print("get login info", dump(res_data))
    game_token, game_host = res_data.token, res_data.host
    socket.close(fd)
end

local conn_to_game = function()
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
    if local_server then
        conn_to_game()
    else
        login()
        conn_to_game()
    end

    send_request("select_player", {
        acc = acc,
        token = game_token or "",
        playerid = playerid
    })
    local _, _, res = recv_data()
    print("select_player", dump(res))

    skynet.fork(function()
        while true do
            local p1, p2, p3 = recv_data()
            print(p1, p2, dump(p3))
            print("----------")
        end
    end)

    skynet.fork(function()
        while true do
            skynet.sleep(1)
            send_request("push_test", {})
        end
    end)
end

skynet.start(function()
    skynet.fork(init_func)
end)
