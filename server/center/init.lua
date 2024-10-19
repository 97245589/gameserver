local require, print, os, pairs = require, print, os, pairs
require "common.tool.lua_tool"
local print_v = print_v
local skynet = require "skynet"
local config = require "common.service.service_config"

local cluster_node
local cluster_heartbeats = {}

local cmds = {}
cmds.heartbeat = function(cluster_name, cluster_host)
    cluster_node[cluster_name] = cluster_host
    cluster_heartbeats[cluster_name] = os.time()
    return cluster_node
end

local dispatch = function()
    skynet.dispatch("lua", function(_, _, cmd, ...)
        local func = cmds[cmd]
        if func then
            skynet.ret(skynet.pack(func(...)))
        else
            skynet.response()(false)
            print("center cmd err", cmd, ...)
        end
    end)
end

local heartbeat_tmout = config.tm.heartbeat_tmout
local check_heartbeat = function()
    skynet.fork(function()
        while true do
            skynet.sleep(100)
            local now_ts = os.time()
            for cluster_name, tm in pairs(cluster_heartbeats) do
                if now_ts > tm + heartbeat_tmout then
                    cluster_heartbeats[cluster_name] = nil
                    cluster_node[cluster_name] = nil
                end
            end
            print_v(cluster_node, os.time())
        end
    end)
end

local start_cluster = function()
    local mgr = require "common.service.cluster_start"
    cluster_node = mgr.cluster_node
end

skynet.start(function()
    start_cluster()
    dispatch()
    check_heartbeat()
end)
