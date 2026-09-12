local skynet = require "skynet"

local M = {}

local mid_addr = {}
local addrs = {}

local create_map = function(idx, mapid)
    local addr = addrs[idx]
    skynet.send(addr, "lua", "create", mapid)
    mid_addr[mapid] = addr
end

local del_map = function(mapid)
    local addr = mid_addr[mapid]
    skynet.send(addr, "lua", "del", mapid)
    mid_addr[mapid] = nil
end

local init = function()
    for i = 1, 2 do
        local addr = skynet.newservice("server/game/map/init")
        table.insert(addrs, addr)
    end

    create_map(1, 100)
end
init()

return M
