local start = require "server.service.service"
local skynet = require "skynet"
local cluster = require "skynet.cluster"

start(function()
    skynet.newservice("server/login/cluster")
    require "server.login.logind"

    local cmd = require "server.func.cmd"

    local acc_server = {}
    cmd.acc_server = function(acc, server)
        local oserver = acc_server[acc]
        if oserver then
            cluster.send(server, "watchdog", "kick_acc", acc)
        end
        acc_server[acc] = server
    end
end, "login")
