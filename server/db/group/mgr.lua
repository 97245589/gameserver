local skynet = require "skynet"
local cluster = require "skynet.cluster"
local cmds = require "server.func.cmd"
local masterf = require "server.db.group.master"
local versionf = require "server.db.group.version"
local db = require "server.db.db"

cmds.cluster_diff = masterf.cluster_diff
cmds.group_master = masterf.group_master
cmds.get_version = versionf.get_version
cmds.sync_data = versionf.syn_data

cmds.master_bygroup = function(group, key)
    local ok, server = masterf.master_bygroup(group)
    if ok then
        versionf.add(key)
    end
    return ok, server
end

local sync_data = function()
    local master = masterf.get_master()
    if not master then
        return
    end
    local nv, data = cluster.call(master, "group", "sync_data", versionf.get_version())
    if nv then
        versionf.set_version(nv)
    end
end
skynet.fork(function()
    while true do
        skynet.sleep(100)
        -- sync_data()
    end
end)
