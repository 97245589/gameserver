local skynet = require "skynet"

local service_addrs = {}

local M = {}

M.set_service_addrs = function(addrs)
    service_addrs = addrs
end

M.rpc_send = function(name, cmd, ...)
    local addr = service_addrs[name]
    skynet.send(addr, "lua", cmd, ...)
end

M.rpc_call = function(name, cmd, ...)
    local addr = service_addrs[name]
    return skynet.call()
end

return M
