local require = require
local os = os
local pairs = pairs
local skynet = require "skynet"
local start = require "common.service.start"
local cmds = require "common.service.cmds"

start(function()
    local print = print
    local dump = dump
    local scluster = require "common.service.cluster"

    local server_host = scluster.get_server_host()
    local server_hearbeat = {}

    cmds.heartbeat = function(server, host)
        server_host[server] = host
        server_hearbeat[server] = os.time()
        return server_host
    end

    skynet.fork(function()
        while true do
            skynet.sleep(100)
            local nowtm = os.time()
            for server, tm in pairs(server_hearbeat) do
                if nowtm > tm + 600 then
                    server_host[server] = nil
                    server_hearbeat[server] = nil
                end
            end
            print("server_host info", dump(server_host))
        end
    end)
end)
