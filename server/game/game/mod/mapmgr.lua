local skynet = require "skynet"

local M = {}
local mapid_addr = {}
local addrs = {}

M.add = function(idx, mapid, info)
    local addr = addrs[idx]
    skynet.send(addr, "lua", "add", mapid, info)
    mapid_addr[mapid] = addr
end

M.del = function(mapid)
    local addr = mapid_addr[mapid]
    skynet.send(addr, "lua", "add", mapid)
    mapid_addr[mapid] = nil
end

M.init = function(num)
    for i = 1, num do
        local addr = skynet.newservice("server/game/map/init")
        table.insert(addrs, addr)
    end
end

return M
