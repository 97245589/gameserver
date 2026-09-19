local start = require "server.service.service"
local skynet = require "skynet"

start(function()
    skynet.newservice("server/db/mgr")
    local sync = skynet.newservice("server/db/sync")

    local sc = require "server.service.cluster"
    sc.set_diff_func("db", function(upd, del)

    end)
end, "init")
