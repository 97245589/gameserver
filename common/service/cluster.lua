local require = require
local io = io
local skynet = require "skynet"
local cluster = require "skynet.cluster"

local intra_host = function()
    local str = [[ip addr | grep "inet " | grep -v "127.0.0.1" | awk '{print $2}']]
    local f = io.popen(str)
    local ip = f:lines()
    f:close()
    local port = skynet.getenv("cluster_port")

end

local server_mark = skynet.getenv("server_mark")

local clusters = {
    center = "0.0.0.0:10020"
}
cluster.reload(clusters)
cluster.open(server_mark)
cluster.register(server_mark, skynet.self())
