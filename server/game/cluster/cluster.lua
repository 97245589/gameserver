local require, tonumber, print = require, tonumber, print
require "common.service.cluster_start"
local skynet = require "skynet"
local crypt = require "skynet.crypt"
local cluster = require "skynet.cluster"

local login_key = crypt.randomkey()
skynet.send("watchdog", "lua", "set_login_key", login_key)

local serverid = tonumber(skynet.getenv("server_id"))
local ip = skynet.getenv("ip")
cluster.send("login1", "@login1", "gameserver_info", serverid, {
    login_key = login_key,
    host = ip .. ":" .. skynet.getenv("gate_port")
})

local cmds = require "common.service.cmds"
cmds.login_kick = function(acc)
    print("login_kick", acc)
end
