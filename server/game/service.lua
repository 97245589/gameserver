local skynet = require "skynet"
local toolf = require "server.func.tool"
require "server.func.tool"

local M = {}

local service_arr = { "character", 5, "game", 1, "watchdog", 1 }
local service_num = {}
for i = 1, #service_arr, 2 do
    local name = service_arr[i]
    local num = service_arr[i + 1]
    service_num[name] = num
end
M.service_arr = service_arr

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
