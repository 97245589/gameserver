local start = require "server.service.service"
local cluster = require "skynet.cluster"
local cmds = require "server.func.cmd"

local acc_server = {}
cmds.acc_server = function(acc, server)
    local oserver = acc_server[acc]
    if oserver then
        cluster.send(server, "watchdog", "kick_acc", acc)
    end
    acc_server[acc] = server
end

start(function()
    require "server.login.logind"
end, "login")
