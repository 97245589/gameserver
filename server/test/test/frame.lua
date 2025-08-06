require "common.tool.lua_tool"
local require, print, dump = require, print, dump
local skynet = require "skynet"
local squeue = require "skynet.queue"

local queue_test = function()
    print("cs test ============")
    local test = function(t)
        print("queue test", t)
        skynet.sleep(200)
    end

    skynet.fork(test)
    skynet.fork(test)

    local cs = squeue()
    cs(test, skynet.now())
    cs(test, skynet.now())
end

local time_test = function()
    print("time test ===========")
    print(skynet.now(), skynet.time(), os.time())
end

skynet.start(function()
    time_test()
    queue_test()
end)
