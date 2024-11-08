local require = require
local skynet = require "skynet"
local crc = require "common.tool.crc"
local config = require "common.service.service_config"

local childnum = config.service_num.login_child
local send2childs = function(...)
    for i = 1, childnum do
        local servicename = "login" .. i
        skynet.send(servicename, "lua", ...)
    end
end

local crc32 = crc.crc32
local callchild = function(acc, cmd, ...)
    local balance = crc32(acc) % childnum + 1
    local name = "login" .. balance
    return skynet.call(name, "lua", cmd, ...)
end

return {
    send2childs = send2childs,
    callchild = callchild
}
