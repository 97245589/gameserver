require "common.tool.lua_tool"
local require, string, print, pairs, os = require, string, print, pairs, os
local print_v, dump = print_v, dump
local skynet = require "skynet"
local crypt = require "skynet.crypt"
local socket = require "skynet.socket"

local config_load = require "common.service.config_load"
local proto = config_load.proto()
local host = proto.host
local request = proto.push_req

local acc, local_server, login_host, game_host, gameid
local session = 1
local fd, game_token, send_request, recv_data, recv_cb

local conn_to_login = function()
    fd = socket.open(login_host)
    print("conn to login server", fd)

    send_request("login_token", {
        acc = acc
    })
    local _, _, res = recv_data()
    -- print("get login token", dump(res))
    local token = res.token

    send_request("gamekey", {
        acc = acc,
        server = gameid,
        token = token
    })

    local _, _, res_data = recv_data()
    -- print("get login info", dump(res_data))
    game_token, game_host = res_data.token, res_data.host
    socket.close(fd)
end

local conn_to_game = function()
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
    return name, session
end

local client_start = function()
    if local_server then
        conn_to_game()
    else
        conn_to_login()
        conn_to_game()
    end
    game_token = game_token or ""

    send_request("verify", {
        acc = acc,
        token = game_token
    })
    local _, _, res = recv_data()
    game_token = res.token
end

return {
    client_start = function(args)
        acc = args.acc or "1993"
        local_server = args.local_server
        login_host = args.login_host or "0.0.0.0:10301"
        game_host = args.game_host or "0.0.0.0:10101"
        gameid = gameid or "1"
        client_start()
    end,
    send_request = send_request,
    recv_data = recv_data,
    get_game_token = function()
        return game_token
    end
}
