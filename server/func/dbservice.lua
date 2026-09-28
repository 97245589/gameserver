local mode = ...
local skynet = require "skynet"

if mode == "child" then
    local start = require "server.service.service"
    local dbimpl = require "server.func.dbimpl"
    local rpc = require "server.func.cmd"
    local SELF

    rpc.set_pdb = function(pdb)
        dbimpl.set_pdb(pdb)
    end

    rpc.ope = function(cmd, ...)
        -- print("dbope", cmd, SELF)
        local f = dbimpl[cmd]
        if not f then
            print("db cmd err not found", cmd, ...)
            return
        end
        return f(...)
    end

    start(function()
        SELF = skynet.self()
    end)
elseif mode == "create" then
    require "skynet.manager"
    local start = require "server.service.service"
    local ldb = require "lgame.leveldb"
    local rpc = require "server.func.cmd"
    local path = "run/db/" .. skynet.getenv("server_name")
    local pdb = ldb.create(path)

    local addrs = {}

    rpc.get_addrs = function()
        return addrs
    end

    rpc.exit = function()
        for _, addr in ipairs(addrs) do
            skynet.kill(addr)
        end
        ldb.release(pdb)
        skynet.exit()
    end

    start(function()
        for i = 1, 3 do
            local addr = skynet.newservice("server/func/dbservice", "child")
            skynet.send(addr, "lua", "set_pdb", pdb)
            table.insert(addrs, addr)
        end
    end)
else
    local caddr = skynet.uniqueservice("server/func/dbservice", "create")

    local IDX = 2
    local addrs = skynet.call(caddr, "lua", "get_addrs")
    local write_cmds = { del = 1, hdel = 1, hmset = 1, hset = 1 }
    local get_addr = function(cmd)
        if write_cmds[cmd] then
            return addrs[1]
        end
        local raddr = addrs[IDX]
        IDX = IDX + 1
        if IDX > #addrs then
            IDX = 2
        end
        return raddr
    end

    return {
        send = function(cmd, ...)
            local addr = get_addr(cmd)
            skynet.send(addr, "lua", "ope", cmd, ...)
        end,
        call = function(cmd, ...)
            local addr = get_addr(cmd)
            return skynet.call(addr, "lua", "ope", cmd, ...)
        end
    }
end
