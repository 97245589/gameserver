local start = require "server.service.service"
local cluster = require "skynet.cluster"

start(function()
    local sc = require "server.service.cluster"
    local server_host = sc.get_server_host()
    sc.set_diff_func(function(upd, del)
        server_host = sc.get_server_host()
        print("diff", dump(upd), dump(del), dump(server_host))
    end)
    require "server.login.logind"
    local cmd = require "server.func.cmd"

    local acc_server = {}
    cmd.acc_server = function(acc, server)
        if not server_host[server] then
            return
        end
        local oserver = acc_server[acc]
        if oserver then
            cluster.send(server, "watchdog", "kick_acc", acc)
        end
        acc_server[acc] = server
        return true
    end
end)
