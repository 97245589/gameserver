local require, os, setmetatable = require, os, setmetatable
local lrank = require "lutil.lrank"

local __mt = {
    __index = {
        add = function(self, id, score, time)
            local core = self.core
            core:add(id, score, time or os.time())
        end,
        dump = function(self)
            local core = self.core
            return core:dump()
        end,
        arr_info = function(self, num)
            local core = self.core
            return core:arr_info(num)
        end
    }
}

local M = {}
M.new_rank = function(num, arr_info)
    local ret = {
        core = lrank.create_lrank(num)
    }
    setmetatable(ret, __mt)

    if arr_info then
        for i = 1, #arr_info, 3 do
            local id = arr_info[i]
            local score = arr_info[i + 1]
            local time = arr_info[i + 2]
            ret:add_rank(id, score, time)
        end
    end

    return ret
end

return M
