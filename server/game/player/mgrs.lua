local cfg = require "common.func.cfg"
local pairs = pairs
local ipairs = ipairs

local M = {}

local inits = {}
local cfgs = {}

M.reload_cfg = function(cfgname)
    cfg.reload(cfgname, function(mnames)
        for name in pairs(mnames) do
            cfgs[name]()
        end
    end)
end

M.add_mgr = function(mgr, name, init_level)
    init_level = init_level or 1
    inits[init_level] = inits[init_level] or {}
    inits[init_level][name] = mgr.init

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

return M
