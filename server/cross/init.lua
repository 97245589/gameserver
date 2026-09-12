local skynet = require "skynet"
local cluster = require "skynet.cluster"
local start = require "server.service.service"
local mapmgr = require "server.game.common.mapmgr"

local server_mark = skynet.getenv("server_mark")
start(function()
    local sc = require "server.service.cluster"
    sc.set_diff_func(function(upd, del)
        print("===", dump(upd))
    end)

    mapmgr.init("server/cross/map", 2)
    mapmgr.add_map(1, 88)
end)
