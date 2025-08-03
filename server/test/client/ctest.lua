local skynet = require "skynet"
require "common.tool.lua_tool"

local acc, playerid = ...
acc = acc or "2000"
playerid = playerid or 2000

local test = function()
    local c = loadfile("server/test/client/client.lua")
    local r = c({
        acc = acc,
        playerid = playerid,
        local_server = true
    })
    local send_request = r.send_request

    r.set_recvcb(function(p1, p2, p3, p4)
        print(p1, p2, dump(p3), p4)
    end)

    r.client_start()

    skynet.fork(function()
        while true do
            skynet.sleep(100)
            send_request("push_test", {})
        end
    end)
end

skynet.start(function()
    skynet.fork(test)
end)
