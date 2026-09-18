local start = require "server.service.service"
local skynet = require "skynet"

local start_service = function()
    local service = require "server.game.service"
    local arr = service.service_arr

    for i = 1, #arr, 2 do
        local name = arr[i]
        local num = arr[i + 1]

        local path = string.format("server/game/%s/init", name)
        if num <= 1 then
            skynet.newservice(path)
        else
            for idx = 1, num do
                skynet.newservice(path, name .. idx)
            end
        end
    end
end

local start_cluster = function()
    local gametype = tonumber(skynet.getenv("gametype"))
    if gametype == 1 then
        return
    end
    require "server.service.cluster"
end

start(function()
    start_service()
    start_cluster()
end, "init")
