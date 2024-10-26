local require, tonumber, split = require, tonumber, split
require "common.service.cluster_start"
local skynet = require "skynet"
local crypt = require "skynet.crypt"
local cluster = require "skynet.cluster"
local config = require "common.service.service_config"
local common = require "server.game.game_common"

local login_key = crypt.randomkey()
local serverid = tonumber(skynet.getenv("server_id"))
local ip = skynet.getenv("ip")

common.send_all_player_service("login_key", login_key)
cluster.send("login1", "@login1", "game_login_info", serverid, {
    login_key = login_key,
    host = ip .. ":" .. skynet.getenv("gate_port")
})
local heartbeat_tm = config.tm.heartbeat_tm
skynet.fork(function()
    while true do
        cluster.send("login1", "@login1", "game_heartbeat", serverid)
        skynet.sleep(heartbeat_tm * 100)
    end
end)
