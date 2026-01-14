local skynet = require "skynet"
local cmds = require "common.service.cmds"
local crc16 = require "skynet.db.redis.crc16"

local M = {}
local addrs = {}
local service_num = {}

cmds.service_addrs = function(addrs_, service_num_)
    addrs = addrs_
    service_num = service_num_
end

M.rpc_send = function(name, cmd, ...)
    skynet.send(addrs[name], "lua", cmd, ...)
end

M.rpc_call = function(name, cmd, ...)
    return skynet.call(addrs[name], "lua", cmd, ...)
end

local idx_addr = function(name, id)
    local num = service_num[name]
    if num == 1 then
        return addrs[name]
    else
        local idx = crc16(id) % num + 1
        return addrs[name .. idx]
    end
end

M.rpc_send_id = function(name, cmd, id, ...)
    local addr = idx_addr(name, id)
    skynet.send(addr, "lua", cmd, id, ...)
end

M.rpc_call_id = function(name, cmd, id, ...)
    local addr = idx_addr(name, id)
    return skynet.call(addr, "lua", cmd, id, ...)
end

return M
