local skynet = require "skynet"
local pairs = pairs
local ipairs = ipairs

skynet.start(function()
    local service_num = {
        player = 5,
        watchdog = 1
    }
    local addrs = {}

    for service, num in pairs(service_num) do
        local init = "server/game/" .. service .. "/init"
        if num == 1 then
            addrs[service] = skynet.newservice(init)
        else
            for i = 1, num do
                addrs[service .. i] = skynet.newservice(init)
            end
        end
    end

    for name, addr in pairs(addrs) do
        skynet.send(addr, "lua", "service_addrs", addrs, service_num)
    end

    skynet.exit()
end)
