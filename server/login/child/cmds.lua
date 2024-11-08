local require, string, table = require, string, table
local os, tonumber, print, print_v, dump = os, tonumber, print, print_v, dump
local skynet = require "skynet"
local cluster = require "skynet.cluster"
local socket = require "skynet.socket"
local crypt = require "skynet.crypt"
local cmds = require "common.service.cmds"

local gameserver = {}
local acc_serverid = {}

cmds.game_login_info = function(id, params)
    print("login child game_login_info", id, dump(params))
    gameserver[id] = params
end

cmds.game_leave = function(gameid)
    print("login child game_leave", gameid)
    gameserver[gameid] = nil
end

cmds.login_req = function(args)
    local acc, server = args.acc, args.server

    print("------", dump(gameserver, "game_info"))

    if acc_serverid[acc] then
        local serverid = acc_serverid[acc]
        -- cluser.send("", "", "lua")
    end
    acc_serverid[acc] = server

    local info = gameserver[server]
    local login_key = info.login_key
    return {
        code = 0,
        host = info.host,
        token = crypt.desencode(login_key, skynet.packstring({acc, os.time()}))
    }
end
