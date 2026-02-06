local require = require
local pairs = pairs
local ipairs = ipairs
local skynet = require "skynet"
require "common.func.tool"

skynet.start(function()
    local startarr = {
        "player", 3, "watchdog", 1, "cluster", 1
    }
    local service_num = {}
    local addrs = {}

    for i = 1, #startarr, 2 do
        local name = startarr[i]
        local num = startarr[i + 1]
        service_num[name] = num
        local init = "server/game/" .. name .. "/init"
        if num == 1 then
            addrs[name] = skynet.newservice(init)
        else
            for i = 1, num do
                addrs[name .. i] = skynet.newservice(init)
            end
        end
    end

    for name, addr in pairs(addrs) do
        skynet.send(addr, "lua", "service_addrs", addrs, service_num)
    end

    -- print("rpc addrs", dump(addrs))
    skynet.exit()
end)
