local skynet = require "skynet"

local mode = ...

if mode == "child" then
    local start = require "server.service.service"
    local ldb = require "lgame.leveldb"
    local dbimpl = require "server.func.dbimpl"
    local cmds = require "server.func.cmd"

    local path = "run/db/" .. skynet.getenv("server_name")
    local pdb = ldb.create(path)
    dbimpl.set_pdb(pdb)

    cmds.exit = function()
        if pdb then
            ldb.release(pdb)
        end
        skynet.exit()
    end

    cmds.ope = function(cmd, ...)
        local f = dbimpl[cmd]
        if not f then
            print("db cmd err not found", cmd, ...)
            return
        end
        return f(...)
    end

    start(function()
    end)
else
    local addr = skynet.uniqueservice("server/func/dbservice", "child")

    -- del keys hgetall hkeys hset hmset hget hmget hdel compact
    return {
        send = function(cmd, ...)
            skynet.send(addr, "lua", "ope", cmd, ...)
        end,
        call = function(cmd, ...)
            return skynet.call(addr, "lua", "ope", cmd, ...)
        end
    }
end
