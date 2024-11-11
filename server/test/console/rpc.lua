local require, print = require, print
local skynet = require "skynet"
local child = ...

if child == "child" then
    skynet.start(function()
        skynet.dispatch("lua", function(_, _, ...)
            skynet.retpack("success")
        end)
    end)
else
    local db
    local test = function()
        local addr = skynet.newservice(SERVICE_NAME, "child")

        local t = skynet.now()
        for i = 1, 100000 do
            local ret = skynet.call(addr, "lua", "hello")
        end
        print(skynet.now() - t)
    end

    local test_redis = function()
        db("set", "hello", "world")
        local t = skynet.now()
        for i = 1, 10000 do
            local ret = db("get", "hello")
        end
        print(skynet.now() - t)
        db("flushdb")
    end

    skynet.start(function()
        db = require"common.service.db".db
        test()
        test_redis()
    end)

end
