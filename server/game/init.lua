local skynet = require "skynet"

skynet.start(function()
    local service = require "server.game.service"

    for name, num in pairs(service.service) do
        local path = string.format("server/game/%s/init", name)
        if num <= 1 then
            skynet.newservice(path, name)
        else
            for i = 1, num do
                skynet.newservice(path, name .. i)
            end
        end
    end
    skynet.exit()
end)
