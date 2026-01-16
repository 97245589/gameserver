local require = require
local io = io
local skynet = require "skynet"
local cluster = require "skynet.cluster"
local fip = require "common.func.ip"

local host = function()
    local ip = fip.private()
    local port = skynet.getenv("cluster_port")
    return ip .. ":" .. port
end

local server_mark = skynet.getenv("server_mark")

local clusters = {
    center = "0.0.0.0:10020"
}
clusters[server_mark] = host()
cluster.reload(clusters)
cluster.open(server_mark)
cluster.register(server_mark, skynet.self())

if server_mark == "center" then
else
end