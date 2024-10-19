local require, print = require, print
local llru = require "lutil.lru"

local ret = {};

ret.create_lru = function(len, evict_cb)
    if not len or not evict_cb then
        print("create lru params err", len, evict_cb)
        return
    end
    local lru = llru.create_lru()
    lru:set_size(len);
    return {
        update = function(id)
            local r = lru:update(id)
            if r then
                evict_cb(r)
            end
        end,
        dump = function()
            print(lru:dump())
        end
    }
end

return ret;
