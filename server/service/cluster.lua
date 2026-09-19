local skynet = require "skynet"
local cluster = require "skynet.cluster"
local toolf = require "server.func.tool"

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

local diff_cb
if server_mark ~= "center" then
    local diff = function(nobj, oobj)
        local upd = {}
        for server, host in pairs(nobj) do
            local ohost = oobj[server]
            if host ~= ohost then
                upd[server] = host
            end
            oobj[server] = nil
        end
        local del = oobj
        return upd, del
    end

    local conn_center = function()
        local bin = cluster.call("center", "@center", "heartbeat", server_mark, shost)
        local nserver_host = skynet.unpack(toolf.decompress(bin))
        local upd, del = diff(nserver_host, server_host)
        server_host = nserver_host
        if next(upd) or next(del) then
            cluster.reload(server_host)
            if diff_cb then
                diff_cb(upd, del)
            end
            -- print("serverhost:", dump(server_host))
        end
    end

    skynet.fork(function()
        while true do
            local ok, err = pcall(conn_center)
            if not ok then
                print(err)
            end
            skynet.sleep(300)
        end
    end)
end

return {
    get_server_host = function()
        return server_host
    end,
    set_diff_cb = function(func)
        diff_cb = func
    end,
}
