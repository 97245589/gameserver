local require = require
local skynet = require "skynet"
local start = require "common.service.start"
local fip = require "common.func.ip"
local cmds = require "common.service.cmds"

local watchdog
local game_host

start(function()
    local rpc = require "server.game.rpc"
    local lserver = skynet.getenv("local_server")
    if lserver then
        return
    end

    skynet.timeout(100, function()
        local addrs = rpc.get_addrs()
        watchdog = addrs.watchdog

        local ip = fip.private()
        local gate_port = skynet.getenv("gate_port")
        game_host = ip .. ":" .. gate_port

        cmds.gameserver_info = function()
            return {
                watchdog = watchdog,
                host = game_host
            }
        end
        require "common.service.cluster"
    end)
end)
