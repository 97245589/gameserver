local skynet = require "skynet"
local start = require "server.service.service"
local cmd = require "server.func.cmd"
local toolf = require "server.func.tool"

start(function()
    local sc = require "server.service.cluster"
    local server_host = sc.get_server_host()
    local server_heartbeat = {}

    cmd.heartbeat = function(server, host)
        server_host[server] = host
        server_heartbeat[server] = os.time()
        return toolf.compress(skynet.packstring(server_host))
    end

    skynet.fork(function()
        while true do
            skynet.sleep(100)
            local tm = os.time()
            for server, heartbeat in pairs(server_heartbeat) do
                if tm > heartbeat + 6 then
                    server_host[server] = nil
                    server_heartbeat[server] = nil
                end
            end
            print("server_host", dump(server_host))
        end
    end)
end)
