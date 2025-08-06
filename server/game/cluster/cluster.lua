local require, print = require, print
require "common.service.cluster_start"
local skynet = require "skynet"
local crypt = require "skynet.crypt"
local cluster = require "skynet.cluster"
local cmds = require "common.service.cmds"
local gamecommon = require "server.game.game_common"

local serverid = skynet.getenv("server_id")
local ip = skynet.getenv("ip")
local gameserver_info = {
    serverid = serverid,
    host = ip .. ":" .. skynet.getenv("gate_port")
}
cluster.send("login1", "@login1", "gameserver_info", gameserver_info)

cmds.login_kick = function(acc)
    print("login_kick", acc)
    gamecommon.send_verify_service("acc_offline", acc)
end

cmds.gameserver_info = function()
    return gameserver_info
end

cmds.set_loginkey = function(acc, key)
    gamecommon.send_verify_service("set_loginkey", acc, key)
end
