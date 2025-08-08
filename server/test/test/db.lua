require "common.tool.lua_tool"
local require = require
local skynet = require "skynet"

local format = string.format

local test = function()
    local db = require "common.service.db"
    local dbsend = db.send
    local dbcall = db.call

    for i = 1, 100 do
        dbcall("set", "hello" .. i, "world" .. i)
    end
    print(dbcall("get", "hello5"), dbcall("get", "hello100"))

    local n = 10000
    local t = skynet.now()
    local get_test = function(m)
        for i = 1, n do
            local ret = dbcall("get", "hello" .. i)
        end
        print(format("%s get %s times cost %s", m, n, skynet.now() - t))
    end

    for i = 1, 2 do
        skynet.fork(get_test, i)
    end
end

local test_scan = function()
    local db = require "common.service.db"
    db.scan("*", 10, function(arr)
        print("test all", #arr)
    end)

    db.scan("*", 5, function(arr)
        print("test maxlen", #arr)
    end, 30)

    db.scan("hello1*", 3, function(arr)
        print(dump(arr, "hello1"))
    end)
end

skynet.start(function()
    test()
    test_scan()
end)
