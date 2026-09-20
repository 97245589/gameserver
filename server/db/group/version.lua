local db = require "server.db.db"

local version = 0

local M = {}

M.add = function(key)
    version = version + 1
end

M.get_version = function()
    return version
end

M.set_version = function(v)
    version = v
end

M.syn_data = function(fversion)

end

return M
