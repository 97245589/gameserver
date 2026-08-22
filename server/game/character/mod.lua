local M = {}

local init_data = {}

M.add_module = function(mod, name)
    if mod.init_data then
        table.insert(init_data, mod.init_data)
    end

    if mod.init_mod then
        mod.init_mod()
    end
end

M.init_character = function(character)
    for _, initf in ipairs(init_data) do
        initf(character)
    end
end

return M
