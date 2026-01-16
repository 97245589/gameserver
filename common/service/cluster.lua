local require = require
local io = io
local pcall = pcall
local pairs = pairs
local next = next
local skynet = require "skynet"
local cluster = require "skynet.cluster"
local fip = require "common.func.ip"

local ip = fip.private()
local port = skynet.getenv("cluster_port")
local host = ip .. ":" .. port
local server_mark = skynet.getenv("server_mark")

local server_host = {
    center = "172.27.158.158:10020"
}
server_host[server_mark] = host
cluster.reload(server_host)
cluster.open(server_mark)
cluster.register(server_mark, skynet.self())

if server_mark ~= "center" then
    local same = function(oobj, nobj)
        for k in pairs(nobj) do
            if not oobj[k] then
                return false
            end
            oobj[k] = nil
        end
        if next(oobj) then
            return false
        end
        return true
    end

    local conn_center = function()
        local ok, ret = pcall(cluster.call, "center", "@center", "heartbeat", server_mark, host)
        if not ok then
            return
        end

        local b = same(server_host, ret)
        server_host = ret
        if not b then
            cluster.reload(server_host)
        end
    end

    skynet.fork(function()
        while true do
            conn_center()
            skynet.sleep(300)
        end
    end)
end

local M = {}

M.get_server_host = function()
    return server_host
end

return M
