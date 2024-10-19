require "common.tool.lua_tool"
local require, print, setmetatable = require, print, setmetatable
local type, tostring, math = type, tostring, math
local pairs, next = pairs, next
local print_v, print_s, dump, split = print_v, print_s, dump, split
local skynet = require "skynet"

local test_split = function()
    local str = "hello/world/haha"
    print_v(split(str, "/"))
end

local pack_test = function()
    local obj = {
        id = 100,
        name = "hello world"
    }
    print(#skynet.packstring(obj))
    setmetatable(obj, {
        __index = {
            get_id = function(obj)
                return obj.id
            end
        }
    })
    print(obj:get_id())
    print(#skynet.packstring(obj))

    local nobj = {
        __INFO = obj
    }
    setmetatable(nobj, {
        __index = obj,
        __newindex = obj,
        __pairs = function(tb)
            return next, tb.__INFO, nil
        end
    })

    print(type(nobj), #skynet.packstring(nobj))
    print_v(nobj)
end

local zstd_test = function()
    local zstd = require "common.tool.zstd"
    local encode = zstd.encode
    local decode = zstd.decode

    local obj = {
        hello = "world"
    }
    for i = 1, 10 do
        obj[i * 100] = {
            id = i * 100,
            name = "haha"
        }
    end
    local bin = encode(obj)
    local tb = decode(bin)
    print(#bin, #skynet.packstring(obj), dump(tb))
    print_s(obj)
end

local dir_require_test = function()
    local reload = require "common.service.service_reload"
    local batch = require "server.game.game.game_batch"
    reload.dir_require("server/game/game/mgr")

    print_v(batch.dump())
    local player = {}
    batch.all_init_data(player)
    print_v(player)
end

local rank_test = function()
    local rank_mgr = require "common.tool.rank"
    local random = math.random

    local rank = rank_mgr.create_rank(1, 1, 10)
    for i = 1, 1000 do
        rank.add_rank(tostring(random(20)), random(10), i)
    end
    rank.dump()
    print_v(rank.info(3))
    local db_data = rank.db_data()

    local nrank = rank_mgr.create_rank(2, 1, 5, db_data)

    for i = 1, 1000 do
        rank_mgr.trigger_rank(1, tostring(random(20)), random(10))
    end
    rank.dump()
    nrank.dump()
end

local lru_test = function()
    local lru_mgr = require "common.tool.lru"

    local data = {}
    local lru = lru_mgr.create_lru(10, function(id)
        print("evict", id, type(id))
        data[id] = nil
    end)

    for i = 1, 100 do
        local id = tostring(math.random(20))
        data[id] = 1
        lru.update(id)
    end
    lru.dump()
    print_v(data)
end

local crypt_test = function()
    local crypt = require "skynet.crypt"

    local key = "hellowor"
    local str = os.time()
    local token = crypt.desencode(key, str)
    print(crypt.desdecode(key, token), #token)

    local clientkey = crypt.randomkey()
    local serverkey = crypt.randomkey()
    local secret = crypt.dhsecret(clientkey, serverkey)
    print(#secret)

    local t1 = skynet.now()
    for i = 1, 1000000 do
        local bin = crypt.desencode(key, str)
        local nstr = crypt.desdecode(key, bin)
    end
    print(skynet.now() - t1)
end

skynet.start(function()
    -- test_split()
    -- pack_test()
    -- zstd_test()
    -- dir_require_test()
    -- rank_test()
    lru_test()
    -- crypt_test()
    skynet.exit()
end)
