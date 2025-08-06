require "common.tool.lua_tool"
local require = require
local type, math, collectgarbage = type, math, collectgarbage
local pairs, next = pairs, next
local print, print_v, dump, split = print, print_v, dump, split
local format = string.format
local skynet = require "skynet"

local split_test = function()
    print("test split ==========")
    local str = "hello/world/haha"
    print(str, dump(split(str)))
end

local zstd_test = function()
    print("zstd test =============")
    local zstd = require "common.tool.zstd"
    local item = {}
    for i = 1, 10000 do
        item[i] = {
            id = i,
            num = i
        }
    end
    local bin = skynet.packstring(item)
    print(format("len: %d, compresslen: %d", #bin, #zstd.compress(bin)))
end

local dir_require_test = function()
    print("dir require test ====================")
    local reload = require "common.service.service_reload"
    local mgrs = require "server.game.player.mgrs"
    reload.dir_require("server/game/player/mgr")

    local player = {}
    mgrs.all_init_player(player)
    print("player init", dump(player))
end

local crypt_test = function()
    print("crypt test =================")
    local crypt = require "skynet.crypt"

    local key = crypt.randomkey()
    local str = skynet.now()
    local bin = crypt.desencode(key, str)
    print("desdecode", str, crypt.desdecode(key, bin))

    local clientkey = crypt.randomkey()
    local serverkey = crypt.randomkey()
    local secret = crypt.dhsecret(clientkey, serverkey)
    print("dhsecret", crypt.dhsecret(clientkey, serverkey) == crypt.dhsecret(serverkey, clientkey))

    local t = skynet.now()
    for i = 1, 1e5 do
        local bin = crypt.desencode(key, str)
        local nstr = crypt.desdecode(key, bin)
    end
    print("des 5e5 times cost", skynet.now() - t)

    local t = skynet.now()
    for i = 1, 1e4 do
        local clientkey = crypt.randomkey()
        local serverkey = crypt.randomkey()
        local secret = crypt.dhsecret(clientkey, serverkey)
    end
    print("dhsecret 1e4 cost", skynet.now() - t)
    skynet.sleep(1)
end

local gc_test = function()
    print("gc test ===================")
    collectgarbage("collect")
    local item = {}
    for i = 1, 1e7 do
        item[i] = {
            id = i,
            num = i * 10
        }
    end
    skynet.sleep(1)
    local t = skynet.now()
    collectgarbage("collect")
    local mem = math.floor(collectgarbage("count") / 1000)
    print(format("memuse: %sM, gctm: %s", mem, skynet.now() - t))

end

skynet.start(function()
    split_test()
    zstd_test()
    dir_require_test()
    crypt_test()
    gc_test()
    skynet.exit()
end)
