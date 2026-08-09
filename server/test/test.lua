local skynet = require "skynet"
require "server.func.print"
local toolf = require "server.func.tool"

local tb = {
    i = 10,
    si = -10,
    dou = -10.101,
    arr = { "hello", 2, 3 },
    map = { [100] = { id = 100 }, [200] = { 10, 20, 30 } }
}
local tool = function()
    print(dump(tb), toolf.tblen(tb))
    -- print(dump(_G, 1))

    local ntb = toolf.clone(tb)
    print(tb, ntb, dump(ntb))

    print(dump(toolf.split("h e/l/ /1//2", " /")))

    local lcrc16 = require "skynet.db.redis.crc16"
    local str = "qweasd123"
    print(toolf.crc16(str), lcrc16(str))
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
        local lruobj = lruf(2)
        lruobj[0] = 0
        lruobj[1] = 10
        -- lruobj[0] = 100
        lruobj[1] = nil
        lruobj[2] = 20
        print(dump(lruobj))
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
        print(#bin, #cbin, #nbin)
        local nobj = skynet.unpack(nbin)
        print(dump(nobj, 2))
    end
end

local leveldb = function()
    local db = require "server.func.ldb"

    db.call("del", "test")
    db.call("hmset", "test", 10, 100, 20, 200)
    print(dump(db.call("hgetall", "test")))

    local t = skynet.now()
    for i = 1, 100000 do
        db.call("hmset", "test", i, i * 10)
    end
    print(skynet.now() - t)
    print(db.call("hget", "test", 38888))
    -- db.call("del", "test")
    -- print(dump(db.call("hgetall", "test")))
    db.call("compact")
    print("compact end")
end

skynet.start(function()
    clib()
    -- tool()
    -- leveldb()
end)
