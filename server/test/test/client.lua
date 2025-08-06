require "common.tool.lua_tool"
local require, print, dump = require, print, dump
local skynet = require "skynet"

local acc, playerid = ...
acc = acc or "2000"
playerid = playerid or "1_2000"

local test = function()
    local client = require "server.test.common.client"
    local send_request = client.send_request
    local recv_data = client.recv_data

    client.client_start({
        acc = acc,
        playerid = playerid,
        local_server = false
    })

    local game_token = client.get_game_token()
    send_request("select_player", {
        acc = acc,
        token = game_token,
        playerid = playerid
    })
    local _, _, res = recv_data()
    print("select_player", playerid, dump(res))

    skynet.fork(function()
        while true do
            skynet.sleep(100)
            send_request("push_test", {})
        end
    end)

    skynet.fork(function()
        while true do
            local p1, p2, p3 = recv_data()
            print("recv:", p1, p2, dump(p3))
        end
    end)
end

skynet.start(function()
    skynet.fork(test)
end)
