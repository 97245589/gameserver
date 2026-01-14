local cfg = require "common.func.cfg"
local pairs = pairs
local ipairs = ipairs

local M = {}

local inits = {}
local ticks = {}
local cfgs = {}

M.reload_cfg = function(cfgname)
    cfg.reload_cfg(cfgname, function(mnames)
        for name in pairs(mnames) do
            cfgs[name]()
        end
    end)
end

M.add_mgr = function(mgr, name, init_level)
    init_level = init_level or 1
    inits[init_level] = inits[init_level] or {}
    inits[init_level][name] = mgr.init

    ticks[name] = mgr.tick
    cfgs[name] = mgr.cfg
    cfg.cfg_func(name, mgr.cfg)
end

M.all_init = function(player)
    for idx, funcs in ipairs(inits) do
        for name, func in pairs(inits) do
            func(player)
        end
    end
end

M.all_tick = function(player, tm)
    for _, tick_func in pairs(ticks) do
        tick_func(player, tm)
    end
end

return M
