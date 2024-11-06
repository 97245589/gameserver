local require, print = require, print
local skynet = require "skynet"

local child = ...

if child == "child" then
    skynet.start(function()
        -- local redis = require "skynet.db.redis"
        -- local db = redis.connect({
        --     host = "127.0.0.1",
        --     port = 6379
        -- })
        skynet.dispatch("lua", function(_, _, cmd, ...)
            -- local ret = db[cmd](db, ...)
            skynet.retpack(cmd)
        end)
    end)
else
    local addr = skynet.uniqueservice("common/service/db", "child")

    local db = function(...)
        return skynet.call(addr, "lua", ...)
    end

    return db
end
