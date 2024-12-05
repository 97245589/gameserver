local require, collectgarbage, print, string = require, collectgarbage, print, string
local table, pairs, ipairs, os, type = table, pairs, ipairs, os, type
local skynet = require "skynet"
local profile = require "skynet.profile"
require "skynet.manager"
local codecache = require "skynet.codecache"
codecache.mode "EXIST"
require "common.tool.lua_tool"
local cmds = require "common.service.cmds"
local profile_info = require "common.service.profile"
local config_load = require "common.service.config_load"
local SERVICE_NAME = SERVICE_NAME

local service_name = ...
if service_name then
    skynet.register(service_name)
end

local package_reload = require "common.service.service_reload"
local service_dir = package_reload.get_service_dir()
-- print("service_dir", service_dir)
local hotreload = function()
    config_load.reload()
    package_reload.remove_hotreload_package()
    package_reload.dir_require(service_dir .. "/cmd")
    package_reload.dir_require(service_dir .. "/mgr")
    collectgarbage("collect")
    -- print(SERVICE_NAME, "memory used", collectgarbage("count") .. "k")
end

local diff_tm = 0
local set_diff_tm = function(tm)
    diff_tm = diff_tm + tm
    print(SERVICE_NAME, "now diff tm", diff_tm)
end
local otime = os.time
os.time = function(p)
    if p then
        return otime(p)
    end
    return otime() + diff_tm
end

cmds.get_diff_tm = function()
    return diff_tm
end
cmds.set_diff_tm = set_diff_tm
cmds.hotreload = hotreload

skynet.start(function()
    skynet.dispatch("lua", function(_, _, cmd, ...)
        local mqlen = skynet.stat("mqlen")
        -- print(SERVICE_NAME, "mqlen ----", mqlen)

        profile.start()
        local func = cmds[cmd]
        if func then
            skynet.retpack(func(...))
        else
            skynet.response()(false)
            print(SERVICE_NAME .. " service lua command not found", cmd)
        end
        local time = profile.stop()
        local cmd_name = "rpc.." .. cmd
        profile_info.add_cmd_profile(cmd_name, time)
    end)
    package_reload.dir_require(service_dir)
    package_reload.add_no_hotreaload_package()
    hotreload()
end)

skynet.info_func(function()
    return profile_info
end)
