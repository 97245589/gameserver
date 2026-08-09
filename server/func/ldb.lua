local skynet = require "skynet"
local leveldb = require "lgame.leveldb"

local mode = ...

if mode == "child" then
    skynet.start(function()
        require "server.func.print"
        local pdb = leveldb.create("run/db/" .. skynet.getenv("server_mark")) -- ldb.release(pdb)

        skynet.dispatch("lua", function(_, _, cmd, ...)
            skynet.retpack(leveldb[cmd](pdb, ...))
        end)
    end)
else
    local addr = skynet.uniqueservice("server/func/ldb", "child")

    -- del keys hgetall hkeys hset hmset hget hmget hdel compact
    return {
        send = function(cmd, ...)
            skynet.send(addr, "lua", cmd, ...)
        end,
        call = function(cmd, ...)
            return skynet.call(addr, "lua", cmd, ...)
        end
    }
end
