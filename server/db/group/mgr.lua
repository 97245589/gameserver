local skynet = require "skynet"
local cluster = require "skynet.cluster"
local cmds = require "server.func.cmd"
local masterf = require "server.db.group.master"

cmds.cluster_diff = masterf.cluster_diff
cmds.group_master = masterf.group_master
cmds.master_bygroup = masterf.master_bygroup
