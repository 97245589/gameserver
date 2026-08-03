local skynet = require "skynet"
local toolf = require "server.func.tool"

local tool = function()
    local tb = {
        i = 10,
        si = -10,
        dou = -10.101,
        arr = { "hello", 2, 3 },
        map = { [100] = { id = 100 }, [200] = { 10, 20, 30 } }
    }
    print(dump(tb), toolf.tblen(tb))
    -- print(dump(_G, 1))

    local ntb = toolf.clone(tb)
    print(tb, ntb, dump(ntb))

    print(dump(toolf.split("h e l 1 2 3")))
end

skynet.start(function()
    tool()
end)
