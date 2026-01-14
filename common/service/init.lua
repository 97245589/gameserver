require "common.tool.tool"
local skynet = require "skynet"
local load = require "common.service.load"
local cmds = require "common.service.cmds"

local init = function()
    skynet.start(function()
        skynet.dispatch("lua", function(_, _, cmd, ...)
            local func = cmds[cmd]
            if func then
                func(...)
            else
                skynet.response()(false)
            end
        end)

        skynet.timeout(30, load.load)
    end)
end

return init
