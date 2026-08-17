local M = {}

local mods = {}
local inits = {}

M.add_module = function(mod, name)
    if mods[name] then
        print("module err", name)
        return
    end
    mods[name] = mod
    if mod.init then
        table.insert(inits, mod.init)
    end
end

M.init_character = function(character)
    for _, initf in ipairs(inits) do
        initf(character)
    end
end

return M
