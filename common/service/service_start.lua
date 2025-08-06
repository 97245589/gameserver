local skynet = require "skynet"

local service_name, load_fork = ...

local start_func = function()
    require "common.tool.lua_tool"
    local require, collectgarbage, print, string = require, collectgarbage, print, string
    local table, pairs, ipairs, os, type = table, pairs, ipairs, os, type
    local profile = require "skynet.profile"
    require "skynet.manager"
    local codecache = require "skynet.codecache"
    codecache.mode "EXIST"
    local cmds = require "common.service.cmds"
    local profile_info = require "common.service.profile"
    local config_load = require "common.service.config_load"

    if service_name then
        skynet.register(service_name)
    end

    local package_reload = require "common.service.service_reload"
    local service_dir = package_reload.get_service_dir()
    -- print("service_dir", service_dir)
    local hotreload = function()
        -- codecache.clear()
        config_load.reload()
        package_reload.remove_hotreload_package()
        package_reload.dir_require(service_dir .. "/cmd")
        package_reload.dir_require(service_dir .. "/mgr")
        -- collectgarbage("collect")
        -- print(SERVICE_NAME, "memory used", collectgarbage("count") .. "k")
    end

    cmds.hotreload = hotreload

    skynet.dispatch("lua", function(_, _, cmd, ...)
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
end

skynet.start(function()
    if load_fork then
        skynet.fork(start_func)
    else
        start_func()
    end
end)
