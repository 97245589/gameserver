local require, pairs = require, pairs
local skynet = require "skynet"
local profile = require "skynet.profile"
local profile_info = require "common.service.profile"

local M = {}

local mgrs = {}
local ticks = {}

M.add_mgr = function(name, mgr)
    mgrs[name] = mgr
    if mgr.tick then
        ticks[name] = mgr.tick
    end
end

M.all_tick = function()
    for name, func in pairs(ticks) do
        profile.start()

        local time = profile.stop()
        local cmd_name = "tick.." .. name
        profile_info.add_cmd_profile(cmd_name, time)
    end
end

return M
