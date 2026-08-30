local skynet = require "skynet"
local cluster = require "skynet.cluster"
local toolf = require "server.func.tool"
require "server.func.print"

local sip = skynet.getenv("priip")
local port = skynet.getenv("cluster_port")
local shost = sip .. ":" .. port
local server_mark = skynet.getenv("server_mark")
local centerhost = skynet.getenv("center")
local server_host = { center = centerhost }
if server_mark ~= "center" then
    server_host[server_mark] = shost
end
cluster.reload(server_host)
cluster.open(server_mark)
cluster.register(server_mark, skynet.self())

local diff_func
if server_mark ~= "center" then
    local diff = function(nobj, oobj)
        for server, host in pairs(nobj) do
            local ohost = oobj[server]
            if host ~= ohost then
                return true
            end
            oobj[server] = nil
        end
        return next(oobj)
    end

    local conn_center = function()
        local bin = cluster.call("center", "@center", "heartbeat", server_mark, shost)
        local nserver_host = skynet.unpack(toolf.decompress(bin))
        if diff(nserver_host, server_host) then
            cluster.reload(nserver_host)
            if diff_func then
                diff_func(nserver_host)
            end
            print("cluster diff", dump(nserver_host))
        end
        server_host = nserver_host
    end

    skynet.fork(function()
        while true do
            conn_center()
            skynet.sleep(300)
        end
    end)
end

return {
    get_server_host = function()
        return server_host
    end,
    set_diff_func = function(func)
        diff_func = func
    end
}
