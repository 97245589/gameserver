local require, print = require, print
local skynet = require "skynet"
local sproto = require "sproto"
require "common.tool.lua_tool"
local print_v = print_v

local effi = function()
    local zstd = require "common.tool.zstd"
    local obj = {
        arr = {}
    }
    local arr = obj.arr
    for i = 1, 20000 do
        arr[i] = {
            id = i,
            level = i * 10
        }
    end
    local sp = sproto.parse [[
        .Test {
            id 0 : integer
            level 1 : integer
        }
        .Obj {
            arr 0 : *Test(id)
        }
    ]]

    local t
    t = skynet.now()
    local sbin, sobj
    for i = 1, 100 do
        sbin = sp:pencode("Obj", obj)
        sbin = zstd.compress(sbin)
    end
    print(#sbin, skynet.now() - t)

    t = skynet.now()
    local zbin, zobj
    for i = 1, 100 do
        zbin = skynet.packstring(obj)
        zbin = zstd.compress(zbin)
    end
    print(#zbin, skynet.now() - t)
end

local encode = function()
    local sp = sproto.parse [[
        .Test {
            .Test1 {
                id 0 : integer
                mark 1 : boolean
            }
            id 0 : integer
            name 1 : string
            ids 2 : *double
            tarr 3 : *Test1
            tobj 4 : *Test1(id)
        }
    ]]

    local test = {
        id = 1,
        name = "haha",
        ids = {2, 1.0, 3.33},
        tarr = {{
            id = 100,
            mark = true
        }, {
            id = 200
        }},
        tobj = {
            [1000] = {
                id = 1000,
                mark = true
            },
            [2000] = {
                id = 2000
            }
        }
    }

    local bin = sp:pencode("Test", test)
    print(#bin)

    print_v(sp:pdecode("Test", bin))
end

local rpc_test = function()
    local proto = {}

    proto.c2s = sproto.parse [[
    .package {
        type 0 : integer
        session 1 : integer
    }

    req_test 2 {
        request {
            key 0 : string
        }
        response {
            val 0 : string
        }
    }
    ]]

    proto.s2c = sproto.parse [[
    .package {
        type 0 : integer
        session 1 : integer
    }
    ]]

    local cli_host = proto.s2c:host "package"
    local cli_req = cli_host:attach(proto.c2s)

    local ser_host = proto.c2s:host "package"
    local ser_req = ser_host:attach(proto.s2c)

    local cli_str = cli_req("req_test", {
        key = "hello"
    }, 1)

    local req, cmd, args, res = ser_host:dispatch(cli_str)
    print("rpc server recv", req, cmd, args, res)

    local ser_str = res({
        val = "world"
    })

    local res, session, args = cli_host:dispatch(ser_str)
    print(res, session)
    print_v(args)

    local t1 = skynet.now()
    for i = 1, 1000000 do
        local req, cmd, args, res = ser_host:dispatch(cli_str)
        local bin = res({
            code = 1
        })
    end
    print("-----------", skynet.now() - t1)
end

local default_test = function()
    local sp = sproto.parse [[
        .Test {
            .Test1 {
                id 0 : integer
                test 1 : integer
            }
            id 0 : integer
            name 1 : string
            ids 2 : *integer
            arr 3 : *Test1
            map 4 : *Test1(id)
        }
    ]]
    print_v(sp:default("Test"))
end

skynet.start(function()
    -- default_test()
    effi()
    -- rpc_test()
    -- encode()
    skynet.exit()
end)
