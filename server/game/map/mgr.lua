local skynet = require "skynet"
local map = require "server.game.map.map"
local cmd = require "server.func.cmd"

local create_instance = map.create_instance
local maps = {}

cmd.create = function(mapid)
    maps[mapid] = create_instance({
        id = mapid
    })
end

cmd.del = function(mapid)
    maps[mapid] = nil
end

cmd.ch_enter = function(mapid, info)
    local m = maps[mapid]
    if not m then
        return
    end
end

skynet.fork(function()
    while true do
        skynet.sleep(20)
        local ok, err = pcall(function()
            for id, ins in pairs(maps) do
                ins.tick()
            end
        end)
        if err then
            print(err)
        end
    end
end)
