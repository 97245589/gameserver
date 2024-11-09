local require, print = require, print
local skynet = require "skynet"

local child = ...

if child == "child" then
    local table = table
    skynet.start(function()
        local redis = require "skynet.db.redis"
        local db
        skynet.dispatch("lua", function(_, _, cmd, ...)
            if not db then
                db = redis.connect {
                    host = "127.0.0.1",
                    port = 6379
                }
            end
            skynet.retpack(db[cmd](db, ...))
        end)
    end)
else
    local addr = skynet.uniqueservice("common/service/db", "child")

    local db = function(...)
        return skynet.call(addr, "lua", ...)
    end

    return db
end
