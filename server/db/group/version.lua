local db = require "server.db.db"

local version = 0

local M = {}

M.add = function(key)

end

M.get_version = function()
    return version
end

return M
