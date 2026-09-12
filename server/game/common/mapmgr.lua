local skynet = require "skynet"

local M = {}

local mapid_addr = {}
local addrs = {}

M.add_map = function(idx, mapid, info)
    local addr = addrs[idx]
    skynet.send(addr, "lua", "add", mapid, info)
end

M.del_map = function(mapid)
    local addr = mapid_addr[mapid]
    skynet.send(addr, "lua", "del", mapid)
    mapid_addr[mapid] = nil
end

M.init = function(path, num)
    for i = 1, num do
        local addr = skynet.newservice(path)
        table.insert(addrs, addr)
    end
end

M.get_info = function()
    return {
        addrs = addrs,
        mapid_addr = mapid_addr
    }
end

return M
