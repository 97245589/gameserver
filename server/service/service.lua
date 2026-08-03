local skynet = require "skynet"
local CMD = require "server.func.cmd"
require "server.func.print"

return function(func, name)
    skynet.start(function()
        if name then
            require "skynet.manager"
            skynet.register(name)
            -- print("reg name", name)
        end

        skynet.dispatch("lua", function(_, _, cmd, ...)
            local f = CMD[cmd]
            if f then
                skynet.retpack(f(...))
            else
                print("no cmd", cmd)
                skynet.response()(false)
            end
        end)

        skynet.fork(func)
    end)
end
