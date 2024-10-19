local require, type, load, error, io, dump = require, type, load, error, io, dump
local string, table, ipairs, pairs = string, table, ipairs, pairs

local lpeg = require "lpeg"

local mgr = {}

local parse_enum = function(str)
    lpeg.locale(lpeg)
    local space = lpeg.space ^ 0

    local var_name_first = (lpeg.alpha + "_") ^ 1
    local var_name_next = (lpeg.alpha + lpeg.alnum + "_") ^ 0
    local var_name = space * lpeg.C(var_name_first * var_name_next) * space

    local enum_start = space * "enum" * space

    local sep = lpeg.S(",\n")
    local elem = lpeg.C((1 - sep) ^ 0)
    local enum_equ = space * "=" * space * elem * space
    local one_enum = lpeg.Ct(var_name * enum_equ ^ 0 * space)
    local enums = one_enum * (sep * one_enum) ^ 0

    local enum_exp = enum_start * var_name * "{" * enums * (lpeg.space + lpeg.S(",};")) ^ 1

    local enum_list = enum_exp ^ 0
    local infos = table.pack(enum_list:match(str))
    return infos
end

local infos_2_enum = function(infos)
    local enums = {}
    local e_str, now_v, checks
    for _, v in ipairs(infos) do
        if type(v) == "string" then
            e_str = v
            now_v = 0
            enums[e_str] = {}
        elseif type(v) == "table" then
            local name, str = table.unpack(v)
            if str then
                now_v = load("return " .. str)()
            end
            enums[e_str][name] = now_v
            now_v = now_v + 1
        end
    end
    return enums
end

mgr.parse_enum = function(str)
    local infos = parse_enum(str)
    local enums = infos_2_enum(infos)
    return enums
end

mgr.gen_enums = function()
    local file = io.open("common/config/enums.h", "r")
    local str = file:read("*a")
    file:close()

    local enums = mgr.parse_enum(str)
    local enums_str = dump(enums)
    enums_str = string.sub(enums_str, 4, #enums_str - 1)
    enums_str = "return " .. enums_str

    local file = io.open("common/config/enums.lua", "w+")
    file:write(enums_str)
    file:close()
end

return mgr
