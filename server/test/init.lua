local require, tostring = require, tostring
local skynet = require "skynet"

local test_clients = function()
    for i = 1000, 1020 do
        skynet.newservice("server/test/client/client", tostring(i), i)
    end
end

skynet.start(function()
    skynet.newservice("server/test/console/console")
    -- skynet.newservice("server/test/reload/start")

    -- skynet.newservice("server/test/client/client", "2000", 2000)
    -- test_clients()
    skynet.exit()
end)
