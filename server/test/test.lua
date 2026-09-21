local skynet = require "skynet"
require "server.func.tool"
local toolf = require "server.func.tool"

local tb = {
    i = 10,
    si = -10,
    dou = -10.101,
    arr = { "hello", 2, 3 },
    map = { [100] = { id = 100 }, [200] = { 10, 20, 30 } },
    [10] = 100,
}
local tool = function()
    local test = function()
        print(toolf.tblen(tb))
        -- print(dump(_G, 1))

        local ntb = toolf.clone(tb)
        print(tb, ntb, dump(ntb))

        print(dump(toolf.split("h e/l/ /1//2", " /")))

        local lcrc16 = require "skynet.db.redis.crc16"
        local str = "qweasd123"
        print(toolf.crc16(str), lcrc16(str))
    end
end

local clib = function()
    local rank = function()
        local lrank = require "lgame.rank"
        local core = lrank.create(1000)
        local t = skynet.now()
        for i = 1, 1000000 do
            core:add(i % 2000, math.random(2000), i)
        end
        print(skynet.now() - t)
        print(core:order(1000))
        print(dump(core:info(100, 110)))
    end

    local lru = function()
        local lruf = require "server.func.lru"
        local obj = lruf(2)
        obj[0] = 0
        obj[1] = 10
        obj[0] = 100
        -- local v = obj[1]
        obj[2] = 20
        print(dump(obj))
        print(obj.__core:dump())
    end

    local msgpack = function()
        local lmsgpack = require "lgame.msgpack"
        local core = lmsgpack.create(1024)
        local bin = core:encode(tb)
        print(dump(lmsgpack.decode(bin)))
    end

    local zstd = function()
        local obj = {}
        for i = 1, 5 do
            obj[i * 10] = tb
        end
        local bin = skynet.packstring(obj)
        local cbin = toolf.compress(bin)
        local nbin = toolf.decompress(cbin)
        print(#bin, #cbin, #nbin, bin == nbin)
        print(dump(skynet.unpack(nbin), 1))
        print(toolf.decompress("hello"), "illegal")
    end

    local trie = function()
        local ltrie = require "lgame.trie"
        local core = ltrie.create()
        for i = 1, 10 do
            core:set(i, i * 10)
        end
        print(dump(core:prefix_range("")))
    end
end

local db_test = function()
    local dbtest = function()
        local db = require "server.func.dbservice"
        db.call("del", "test")
        db.call("hmset", "test", 10, 100, 20, 200, 50, 500)
        print(dump(db.call("keys", "*")))
        print(dump(db.call("hmget", "test", 10, 60, 20)))
        print(dump(db.call("hgetall", "test")))
        db.call("hdel", "test", 20, 100, 10)
        print(dump(db.call("hgetall", "test")))
        db.call("del", "test")
        print(dump(db.call("hgetall", "test")))
        db.call("compact")
        print("compact end")
    end

    local dbpress = function()
        local db = require "server.func.dbservice"
        db.call("del", "test")
        local t = skynet.now()
        for i = 1, 1000000 do
            db.call("hset", "test", "hello" .. i, "test world" .. i)
        end
        print(skynet.now() - t, db.call("hget", "test", "hello" .. 999999))
        -- db.call("del", "test")
        db.call("compact")
        print("compact end")
    end

    local redis_test = function()
        local redis = require "skynet.db.redis"
        local db = redis.connect({ host = "127.0.0.1", port = 6379 })

        for i = 1, 50 do
            db:hset("test", "hello" .. i, "world" .. i)
        end
        print(dump(db:hkeys("test")))

        db:flushall()
        db:disconnect()
    end
end

skynet.start(function()
    tool()
    clib()
    db_test()
end)
