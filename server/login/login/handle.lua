local mode = ...
if mode ~= "child" then
    return
end

local require, print, dump, os = require, print, dump, os
local skynet = require "skynet"
local cluster = require "skynet.cluster"
local crypt = require "skynet.crypt"

local game_servers = {}
local acc_serverid = {}

local cmds = {
    gameserver_info = function(serverid, info)
        game_servers[serverid] = info
        print("add gameserver", serverid, dump(info))
    end,
    gameserver_down = function(gameid)
        print("login gameserver down", gameid)
        game_servers[gameid] = nil
    end,
    login_req = function(args)
        local acc, server = args.acc, args.server

        if acc_serverid[acc] ~= server then
            local serverid = acc_serverid[acc]
            local addr = "game" .. serverid
            cluster.send(addr, "@" .. addr, "login_kick", acc)
        end
        acc_serverid[acc] = server

        local info = game_servers[server]
        local login_key = info.login_key
        return {
            code = 0,
            host = info.host,
            token = crypt.desencode(login_key, skynet.packstring({acc, os.time()}))
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
