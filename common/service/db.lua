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
                    host = "0.0.0.0",
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

    local traversal = function(match, count, func)
        local cursor = 0
        while true do
            local arr = db("scan", cursor, "MATCH", match, "COUNT", count)
            cursor = arr[1]
            func(arr[2])
            if "0" == cursor then
                return
            end
        end
    end

    return {
        db = db,
        traversal = traversal
    }
end
