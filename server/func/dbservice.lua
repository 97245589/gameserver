local skynet = require "skynet"

local mode = ...

if mode == "child" then
    skynet.start(function()
        local dbimpl = require "server.func.dbimpl"
        require "server.func.print"
        local ldb = require "lgame.leveldb"
        local path = "run/db/" .. skynet.getenv("server_mark")
        local pdb = ldb.create(path)
        dbimpl.set_pdb(pdb)

        skynet.dispatch("lua", function(_, _, cmd, ...)
            if cmd == "exit" then
                skynet.retpack()
                ldb.release(pdb)
                skynet.exit()
                return
            end
            local f = dbimpl[cmd]
            if not f then
                print("dbservice err no cmd", cmd)
            end
            skynet.retpack(f(...))
        end)
    end)
else
    local addr = skynet.uniqueservice("server/func/dbservice", "child")

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
