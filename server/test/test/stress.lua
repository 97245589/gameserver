require "common.tool.lua_tool"
local require, tostring, loadfile = require, tostring, loadfile
local skynet = require "skynet"

local mode, acc, playerid, local_server = ...

if mode == "child" then
    local cli = function()
        local c = loadfile("server/test/client/client.lua")
        local r = c({
            acc = acc,
            playerid = playerid,
            local_server = local_server
        })
        local send_request = r.send_request

        r.set_recvcb(function(p1, p2, p3, p4)
            -- print(p1, p2, dump(p3), p4)
        end)

        r.client_start()

        skynet.fork(function()
            while true do
                skynet.sleep(1)
                send_request("push_test", {})
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
            skynet.newservice("server/test/test/stress", "child", tostring(i), i, 1)
        end
    end)
end

