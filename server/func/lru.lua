local llru = require "lgame.lru"

local __meta = {
    __index = function(tb, k)
        local core = tb.__core
        local info = tb.__info
        local v = info[k]
        if v ~= nil then
            core:update(k)
        end
        return v
    end,
    __newindex = function(tb, k, v)
        local core = tb.__core
        local info = tb.__info
        if v ~= nil then
            local evict = core:update(k)
            if evict then
                info[evict] = nil
            end
        else
            core:del(k)
        end
        info[k] = v
    end
}

return function(num)
    local tb = {
        __info = {},
        __core = llru.create(num)
    }
    setmetatable(tb, __meta)
    return tb
end
