local mode = ...

require "common.tool.lua_tool"
local require, print = require, print
local skynet = require "skynet"
local format = string.format

if mode == "child" then
    require "skynet.manager"
    skynet.register("test")
    skynet.start(function()
        skynet.dispatch("lua", function(_, _, ...)
            skynet.retpack("success")
        end)
    end)
else
    local db
    local test = function()
        local addr = skynet.newservice("server/test/test/rpc", "child")

        local n = 1e5
        local t = skynet.now()
        for i = 1, n do
            local ret = skynet.call(addr, "lua", "hello")
        end
        print(format("skynet call %s times cost: %s", n, skynet.now() - t))

        t = skynet.now()
        for i = 1, n do
            local ret = skynet.call("test", "lua", "hello")
        end
        print(format("skynet name call %s times cost: %s", n, skynet.now() - t))
    end

    local test_redis = function()
        db("set", "hello", "world")
        local t = skynet.now()
        local n = 1e4
        for i = 1, n do
            local ret = db("get", "hello")
        end
        print(format("redis call %s times cost: %s", n, skynet.now() - t))
        db("flushdb")
    end

    skynet.start(function()
        db = require"common.service.db".db
        test()
        test_redis()
    end)
end
