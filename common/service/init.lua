local skynet = require "skynet"
local load = require "common.service.load"

local cmds = {}

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

        load.load()
    end)
end

return {
    init = init,
    cmds = cmds
}
