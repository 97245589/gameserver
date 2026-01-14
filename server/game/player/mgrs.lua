local pairs = pairs
local ipairs = ipairs

local M = {}

local inits = {}
local ticks = {}

M.add_mgr = function(mgr, name, init_level)
    init_level = init_level or 1
    inits[init_level] = inits[init_level] or {}
    inits[init_level][name] = mgr.init
    ticks[name] = mgr.tick
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
