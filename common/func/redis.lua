local skynet = require "skynet"

local mode = ...

if mode == "child" then
    skynet.start(function()
        local redis = require "skynet.db.redis"
        local db
        skynet.dispatch("lua", function(_, _, cmd, ...)
            if not db then
                db = redis.connect({
                    host = "0.0.0.0",
                    port = 6379
                })
            end
            skynet.retpack(db[cmd](db, ...))
        end)
    end)
else
    local addr = skynet.uniqueservice("common/func/redis", "child")
    local M = {}

    M.send = function(...)
        skynet.send(addr, "lua", ...)
    end

    M.call = function(...)
        return skynet.call(addr, "lua", ...)
    end

    return M
end
