local cmds = require "server.func.cmd"
local master = require "server.db.group.master"
local version = require "server.db.group.version"

cmds.cluster_diff = master.cluster_diff
cmds.group_master = master.group_master
cmds.get_version = version.get_version

cmds.master_bygroup = function(group, key)
    local ok, server = master.master_bygroup(group)
    if ok then
        version.add(key)
    end
    return ok, server
end
