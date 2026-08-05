local llru = require "lgame.lru"

return function(num)
    local core = llru.create(num)

    local obj = {
        __INFO = {}
    }
    setmetatable(obj, {
        __index = function(tb, k)
            local v = tb.__INFO[k]
            if v then
                core:update(k)
            end
            return v
        end,
        __newindex = function(tb, k, v)
            if v ~= nil then
                local evict = core:update(k)
                if evict then
                    tb.__INFO[evict] = nil
                end
            else
                core:del(k)
            end
            tb.__INFO[k] = v
        end,
    })
    return obj
end
