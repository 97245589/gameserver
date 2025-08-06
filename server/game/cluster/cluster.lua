local require, print = require, print
require "common.service.cluster_start"
local skynet = require "skynet"
local crypt = require "skynet.crypt"
local cluster = require "skynet.cluster"
local cmds = require "common.service.cmds"

local login_key = crypt.randomkey()
skynet.send("watchdogh", "lua", "set_login_key", login_key)

local serverid = skynet.getenv("server_id")
local ip = skynet.getenv("ip")
local gameserver_info = {
    serverid = serverid,
    loginkey = login_key,
    host = ip .. ":" .. skynet.getenv("gate_port")
}
cluster.send("login1", "@login1", "gameserver_info", gameserver_info)

cmds.login_kick = function(acc)
    print("login_kick", acc)
end

cmds.gameserver_info = function()
    return gameserver_info
end
