local require = require
require "common.tool.tool"
local skynet = require "skynet"
local codecache = require "skynet.codecache"
codecache.mode "OFF"
local cmds = require "common.service.cmds"

local start = function(func)
    skynet.start(function()
        skynet.dispatch("lua", function(_, _, cmd, ...)
            local func = cmds[cmd]
            if func then
                skynet.retpack(func(...))
            else
                skynet.response()(false)
            end
        end)

        func()
    end)
end

return start
