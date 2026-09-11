local M = {}
local configs = {}

local get_config = function(name)
    local path = string.format("server/config/game/%s.lua", name)
    return dofile(path)
end

M.get = function(name)
    local c = configs[name]
    if c then
        return c
    end
    c = get_config(name)
    configs[name] = c
    return c
end

M.overwrite = function(name)
    local c = configs[name]
    if not c then
        configs[name] = get_config(name)
        return
    end
    for k in pairs(c) do
        c[k] = nil
    end
    local nc = get_config(name)
    for k, v in pairs(nc) do
        c[k] = v
    end
end

return M
