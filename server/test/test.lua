local require = require
require "common.func.tool"
local skynet = require "skynet"

local rank = function()
    local lrank = require "lgame.rank"
end

local zstd = function()
    local zstd = require "common.func.zstd"
    local bin = zstd.encode({
        hello = "world"
    })
    print(dump(zstd.decode(bin)))
end

local leveldb = function()
    local db = require "common.func.leveldb"
    db.call("hmset", "test", 1, 10, 2, 20)
    print(dump(db.call("hgetall", "test")))

    --[[
    local ldb = require "lgame.leveldb"
    local db = ldb.create("db/test")

    local str = ""
    for i = 1, 10000 do
        str = str .. "helloworld"
    end
    print(#str)

    local t = skynet.now()
    for i = 1, 3000 do
        db:hmset("test" .. i, "info", str)
    end
    print(skynet.now() - t)
    skynet.sleep(1)
    db:compact()
    ]]
end

local cfg = function()
    local cfg = require "common.func.cfg"
    while true do
        skynet.sleep(100)
        print(dump(cfg.get("item")))
        cfg.reload("item")
    end
end

local ip = function()
    local ip = require "common.func.ip"
    print(ip.private())
    print(ip.public())
end

skynet.start(function()
end)
