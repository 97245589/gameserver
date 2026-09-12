local skynet = require "skynet"
local start = require "server.service.service"
local cmd = require "server.func.cmd"

local M = {}

local maps = {}
local impls = {}

cmd.add = function(mapid, info)
    info = info or {}
    info.id = mapid
    maps[mapid] = M.create_instance(info)
end

cmd.del = function(mapid)
    maps[mapid] = nil
end

M.start = function(func)
    start(func)
end

M.set_map_impl = function(mapid, tb)
    if impls[mapid] then
        print("set map impl err", mapid)
        return
    end
    impls[mapid] = tb
end

M.create_instance = function(info)
    print("map create instance", dump(info))
    local impl = impls[info.id]
    local ins = {}

    ins.tick = function()
    end
    return ins
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

return M
