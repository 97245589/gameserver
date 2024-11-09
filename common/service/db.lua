local require, print = require, print
local skynet = require "skynet"

local child = ...

if child == "child" then
    local table = table
    skynet.start(function()
        local redis = require "skynet.db.redis"
        local pools = {}
        local get_db = function()
            if pools[1] then
                local db = pools[#pools]
                table.remove(pools)
                return db
            else
                local db = redis.connect {
                    host = "127.0.0.1",
                    port = 6379
                }
                return db
            end
        end
        local push_db = function(db)
            table.insert(pools, db)
        end

        skynet.dispatch("lua", function(_, _, cmd, ...)
            local db = get_db()
            skynet.retpack(db[cmd](db, ...))
            push_db(db)
        end)
    end)
else
    local addr = skynet.uniqueservice("common/service/db", "child")

    local db = function(...)
        return skynet.call(addr, "lua", ...)
    end

    return db
end
