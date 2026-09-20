local cluster = require "skynet.cluster"
local cmds = require "server.func.cmd"
local groupf = require "server.db.mgr.group"
local slotf = require "server.db.mgr.slot"
local cfg = require "server.db.cfg"
local ope = require "server.db.mgr.ope"

cmds.group_master = groupf.group_master
cmds.cluster_diff = groupf.cluster_diff

local read_cmds = cfg.read_cmds
local write_cmds = cfg.write_cmds
cmds.ope = function(cmd, key, ...)
    if not read_cmds[cmd] and not write_cmds[cmd] then
        return
    end
    local group = slotf.group_by_key(key)
    local ok, master = groupf.master_bygroup(group)
    if ok then
        return ope.ope(cmd, key, ...)
    end
    if master then
        return cluster.call(master, "mgr", "ope", key, ...)
    end
end
