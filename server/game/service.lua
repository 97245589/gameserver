local skynet = require "skynet"
local toolf = require "server.func.tool"

local M = {}

local service_num = {
    character = 5,
    watchdog = 1,
    game = 1,
    cluster = 1,
}
M.service = service_num

local get_name = function(name, id)
    local num = service_num[name]
    local idx = id % num + 1
    return name .. idx
end

M.send_id = function(name, cmd, id, ...)
    skynet.send(get_name(name, id), "lua", cmd, id, ...)
end

M.call_id = function(name, cmd, id, ...)
    return skynet.call(get_name(name, id), "lua", cmd, id, ...)
end

M.send_all = function(name, ...)
    local num = service_num[name]
    if not num then
        error("rpc sendall err " .. name)
    elseif 1 == num then
        skynet.send(name, "lua", ...)
    else
        for i = 1, num do
            skynet.send(name .. i, "lua", ...)
        end
    end
end

return M
