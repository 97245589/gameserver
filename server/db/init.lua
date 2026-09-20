local start = require "server.service.service"
local skynet = require "skynet"

start(function()
    local maddr = skynet.newservice("server/db/mgr/init")
    local sc = require "server.service.cluster"
    sc.set_diff_cb(function(upd, del)
        skynet.send(maddr, "lua", "cluster_diff", upd, del)
    end)
end)
