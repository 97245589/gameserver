local M = {}

local mods = {}
local inits = {}

M.add_module = function(mod, name)
    mods[name] = mod
    if mod.init then
        table.insert(inits, mod.init)
    end
end

M.init_player = function(player)
    for _, initf in ipairs(inits) do
        initf(player)
    end
end

return M
