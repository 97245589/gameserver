local require, os, pairs = require, os, pairs
require "common.service.cluster_start"
local skynet = require "skynet"
local config = require "common.service.service_config"
local common = require "server.login.login_common"

local game_heartbeat = {}
local cmds = require "common.service.cmds"

local send2childs = common.send2childs
local callchild = common.callchild
cmds.game_login_info = function(id, params)
    send2childs("game_login_info", id, params)
end

cmds.game_heartbeat = function(gameid, loginkey)
    game_heartbeat[gameid] = os.time()
end

local check_heartbeat = function()
    local heartbeat_tmout = config.tm.heartbeat_tmout
    skynet.fork(function()
        while true do
            skynet.sleep(100)
            local now_ts = os.time()
            for gameid, tm in pairs(game_heartbeat) do
                if now_ts > tm + heartbeat_tmout then
                    game_heartbeat[gameid] = nil
                    send2childs("game_leave", gameid)
                end
            end
        end
    end)
end
check_heartbeat()
