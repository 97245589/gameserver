local require, tostring = require, tostring
local skynet = require "skynet"

local test_clients = function()
    for i = 1000, 1100 do
        skynet.newservice("server/test/client/stress", tostring(i), i)
    end
end

skynet.start(function()
    -- skynet.newservice("server/test/console/console")
    -- skynet.newservice("server/test/reload/start")

    -- skynet.newservice("server/test/client/ctest")
    test_clients()
    skynet.exit()
end)
