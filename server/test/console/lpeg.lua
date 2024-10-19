local require = require
require "common.tool.lua_tool"
local print, print_v, dump = print, print_v, dump
local parse_enum = require "common.tool.parse_enum"

local skynet = require "skynet"

local lpeg = require "lpeg"

local simple = function()
    local r
    lpeg.locale(lpeg)
    local space = lpeg.space ^ 0

    local name = lpeg.alpha ^ 1
    print(name:match("hahayes"))

    local name = lpeg.C(lpeg.alpha ^ 1) * space
    r = name:match("hahaha")

    local sep = lpeg.S(",;") * space
    local pair = lpeg.Cg(space * name * "=" * space * name) * sep ^ -1
    print(pair:match("hello = world"))

    local mul_pair = lpeg.Ct(pair ^ 0)
    print_v(mul_pair:match("hello = world, test = test1"))

    local mul_pair = lpeg.Cf(lpeg.Ct("") * pair ^ 0, function(tb, v1, v2)
        tb[v1] = v2
        print("---tt", v1, v2, dump(tb))
        return tb
    end)
    mul_pair:match("hello = world, test = testt")
end

local enum_parse = function()
    local enum_str = [[
        enum ATTR {
            HP,
            ATK = 10,
            DEF = 1 << 2,
        };

        enum ACTSTAUTS {
            ON=1,CLOSE
        };
    ]]

    local enums_table = parse_enum.parse_enum(enum_str)
    print(dump(enums_table, "enums"))
end

local gen_enums = function()
    parse_enum.gen_enums()
end

skynet.start(function()
    simple()
    enum_parse()
    -- gen_enums()
    skynet.exit()
end)
