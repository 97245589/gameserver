local skynet = require "skynet"
local cmd = require "server.func.cmd"
local mapf = require "server.func.map"

local maps = {}
local map_impl = {}

cmd.add = function(mapid, info)
    info = info or {}
    info.mapid = mapid
    info.impl = map_impl[mapid]
    maps[mapid] = mapf.create_instance(info)
end

cmd.del = function(mapid)
    maps[mapid] = nil
end
