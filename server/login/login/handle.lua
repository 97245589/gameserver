local mode = ...
if mode ~= "child" then
    return
end

local require, print, os = require, print, os
require "common.tool.lua_tool"
local dump = dump
local skynet = require "skynet"
local cluster = require "skynet.cluster"
local crypt = require "skynet.crypt"
local skynetps = skynet.packstring
local desen = crypt.desencode

local game_servers = {}
local acc_serverid = {}

local cmds = {
    gameserver_info = function(args)
        print("add gameserver", dump(args))
        local serverid = args.serverid
        game_servers[serverid] = args
    end,
    gameserver_down = function(gameid)
        print("login gameserver down", gameid)
        game_servers[gameid] = nil
    end,
    login_req = function(acc, server)
        local bserver = acc_serverid[acc]
        if bserver and bserver ~= server then
            local serverid = acc_serverid[acc]
            local addr = "game" .. serverid
            cluster.send(addr, "@" .. addr, "login_kick", acc)
        end
        acc_serverid[acc] = server

        local info = game_servers[server]
        local loginkey = info.loginkey
        local token = desen(loginkey, skynetps({acc, skynet.time()}))
        return {
            code = 0,
            host = info.host,
            token = token
        }
    end

}

skynet.start(function()
    skynet.dispatch("lua", function(_, _, cmd, ...)
        local func = cmds[cmd]
        if func then
            skynet.retpack(func(...))
        else
            skynet.response()(false)
        end
    end)
end)
