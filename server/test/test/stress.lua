require "common.tool.lua_tool"
local require, tostring, loadfile = require, tostring, loadfile
local skynet = require "skynet"
local print, dump = print, dump

local mode, acc, playerid, local_server = ...

if mode == "child" then
    local cli = function()
        local client = require "server.test.common.client"
        local send_request = client.send_request
        local recv_data = client.recv_data

        client.client_start({
            acc = acc,
            playerid = playerid,
            local_server = true
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
            end
        end)
    end

    skynet.start(function()
        skynet.fork(cli)
    end)
else
    local client_num = 100
    skynet.start(function()
        for i = 1, client_num do
            skynet.newservice("server/test/test/stress", "child", tostring(i), "1_" .. i, 1)
        end
    end)
end

