local require, os, setmetatable = require, os, setmetatable
local lrank = require "lutil.lrank"

local M = {}
M.new_rank = function(num)
    local core = lrank.create_lrank(num)
    return {
        add = function(id, score, time)
            core:add(id, score, time or os.time())
        end,
        dump = function()
            return core:dump()
        end,
        arr_info = function(num)
            return core:arr_info(num)
        end
    }
end

return M
