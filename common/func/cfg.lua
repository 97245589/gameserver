local require = require
local package = package
local pairs = pairs
local M = {}

local mname
local cfg_mgr = {}

M.cfg_func = function(mgrname, func)
    mname = mgrname
    func()
    mname = nil
end

M.load_cfg = function(cfgname)
    if mname then
        cfg_mgr[cfgname] = cfg_mgr[cfgname] or {}
        cfg_mgr[cfgname][mname] = 1
    end
    local cfg_path = "config." .. cfgname
    return require(cfg_path)
end

M.reload_cfg = function(cfgname, func)
    local cfg_path = "config." .. cfgname
    package.loaded[cfg_path] = nil

    local mnames = cfg_mgr[cfgname]
    if mnames then
        func(mnames)
    end
end

return M
