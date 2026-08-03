local skynet = require "skynet"
local cmds = require "server.func.cmds"
require "server.func.print"

return function(func, name)
    skynet.start(function()
        if name then
            require "skynet.manager"
            skynet.register(name)
        end

        skynet.dispatch("lua", function(_, _, cmd, ...)
            local f = cmds[cmd]
            if f then
                skynet.retpack(f(...))
            else
                print("no cmd", cmd)
                skynet.response()(false)
            end
        end)

        func()
    end)
end
