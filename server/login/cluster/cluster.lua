local require, print, dump = require, print, dump
local string, pairs, pcall = string, pairs, pcall
local skynet = require "skynet"
local cluster = require "skynet.cluster"
local cluster_start = require "common.service.cluster_start"
local cmds = require "common.service.cmds"
local ssub = string.sub

local game_servers = {}

local send_gameservers = function()
    skynet.send("login", "lua", "game_servers", game_servers)
end

cluster_start.set_diff_func(function(diff)
    local adds = diff.adds
    if not adds then
        return
    end
    local m
    for servername, _ in pairs(adds) do
        local str = ssub(servername, 1, 4)
        if str ~= "game" then
            goto continue
        end
        m = true
        local ret = cluster.call(servername, "@" .. servername, "gameserver_info")
        game_servers[ret.serverid] = ret
        print("req gameserverinfo", servername, dump(ret))
        ::continue::
    end
    if m then
        send_gameservers()
    end
end)

cmds.gameserver_info = function(args)
    print("gameserver_info", dump(args))
    game_servers[args.serverid] = args
    send_gameservers()
end
