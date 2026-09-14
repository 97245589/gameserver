local skynet = require "skynet"
local cluster = require "skynet.cluster"
require "server.func.print"

local M = {}

M.create_instance = function(info)
    print("map create instance", dump(info, 2))
    local ins = {}

    ins.tick = function()
    end

    return ins
end

return M
