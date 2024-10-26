local require, print, print_v, dump, pcall = require, print, print_v, dump, pcall
local pairs, ipairs, table = pairs, ipairs, table

local skynet = require "skynet"
local cluster = require "skynet.cluster"
local config = require "common.service.service_config"

local cluster_name = skynet.getenv("server_name") .. skynet.getenv("server_id")
local host = skynet.getenv("ip") .. ":" .. skynet.getenv("cluster_port")
print("clustername :", cluster_name, "cluster_host :", host)

local cluster_node = {}
cluster_node[cluster_name] = host
cluster_node.center1 = config.cluster_node.center1
cluster.reload(cluster_node)
cluster.open(cluster_name)
cluster.register(cluster_name, skynet.self())

local node_conn_to_center = function()
    local ok, ret = pcall(cluster.call, "center1", "@center1", "heartbeat", cluster_name, host)
    if not ok then
        return
    end
    cluster_node = ret
    local t1 = skynet.now()
    cluster.reload(cluster_node)
    -- print("cluster reload spend tm", skynet.now() - t1, dump(ret))
end

skynet.fork(function()
    if "center" ~= skynet.getenv("server_name") then
        while true do
            node_conn_to_center()
            skynet.sleep(100 * config.tm.heartbeat_tm)
        end
    end
end)

return {
    cluster_node = cluster_node
}
