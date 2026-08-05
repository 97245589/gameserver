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
    msgpack()
end

skynet.start(function()
    clib()
    -- tool()
end)
