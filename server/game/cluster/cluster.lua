local require, tonumber, split = require, tonumber, split
require "common.service.cluster_start"
local skynet = require "skynet"
local crypt = require "skynet.crypt"
local cluster = require "skynet.cluster"
local config = require "common.service.service_config"

local login_key = crypt.randomkey()
local serverid = tonumber(skynet.getenv("server_id"))
local ip = skynet.getenv("ip")

skynet.send("watchdog", "lua", "set_login_key", login_key)
cluster.send("login1", "@login1", "game_login_info", serverid, {
    login_key = login_key,
    host = ip .. ":" .. skynet.getenv("gate_port")
})
