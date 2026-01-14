local skynet = require "skynet"
local pairs = pairs
local ipairs = ipairs

skynet.start(function()
    local start_service = {{"watchdog", 1, 0}, {"player", 5, 10}}
    local service_num = {}
    local addrs = {}

    for idx, info in ipairs(start_service) do
        local service, num, tmout = info[1], info[2], info[3]
        service_num[service] = num

        local init = "server/game/" .. service .. "/init"
        if num == 1 then
            addrs[service] = skynet.newservice(init, tmout)
        else
            for i = 1, num do
                addrs[service .. i] = skynet.newservice(init, tmout)
            end
        end
    end

    for name, addr in pairs(addrs) do
        skynet.send(addr, "lua", "service_addrs", addrs, service_num)
    end

    skynet.exit()
end)
