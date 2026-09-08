local skynet = require "skynet"
local start = require "server.service.service"
local cmd = require "server.func.cmd"
local toolf = require "server.func.tool"
local timerf = require "server.func.timer"

start(function()
    local sc = require "server.service.cluster"
    local server_host = sc.get_server_host()
    local timer = timerf(function(_, server)
        server_host[server] = nil
        print("timeout", server, dump(server_host))
    end)

    cmd.heartbeat = function(server, host)
        server_host[server] = host
        timer.add(0, os.time() + 6, server)
        return toolf.compress(skynet.packstring(server_host))
    end

    skynet.fork(function()
        while true do
            skynet.sleep(100)
            timer.expire(os.time())
        end
    end)
end)
