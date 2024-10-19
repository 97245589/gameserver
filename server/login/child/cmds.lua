local require, split, string, table = require, split, string, table
local os, tonumber, print, print_v, dump = os, tonumber, print, print_v, dump
local skynet = require "skynet"
local socket = require "skynet.socket"
local crypt = require "skynet.crypt"
local cmds = require "common.service.cmds"

local game_info = {}

cmds.game_login_info = function(id, params)
    print("login child game_login_info", id, dump(params))
    game_info[id] = params
end

cmds.game_leave = function(gameid)
    print("login child game_leave", gameid)
    game_info[gameid] = nil
end

cmds.login_req = function(args)
    local acc, server = args.acc, args.server

    print("------", dump(game_info, "game_info"))

    local info = game_info[server]
    local login_key = info.login_key

    return {
        code = 0,
        host = info.host,
        token = crypt.desencode(login_key, skynet.packstring({acc, os.time()}))
    }
end
