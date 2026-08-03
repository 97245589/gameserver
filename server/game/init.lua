local skynet = require "skynet"

skynet.start(function()
    local service = require "server.game.service"

    local pathf = "server/game/%s/init"
    for name, num in pairs(service.service) do
        if num <= 1 then
            local path = string.format(pathf, name)
            skynet.newservice(path, name)
        else
            for i = 1, num do
                local path = string.format(pathf, name)
                skynet.newservice(path, name .. i)
            end
        end
    end

    skynet.exit()
end)
