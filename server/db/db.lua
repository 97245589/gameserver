local mode = ...

local skynet = require "skynet"

if mode == "child" then
    local start = require "server.service.service"
    local cmds = require "server.func.cmd"
    local dbimpl = require "server.func.dbimpl"

    cmds.set_pdb = function(pdb)
        dbimpl.set_pdb(pdb)
    end

    cmds.ope = function(cmd, ...)
        return dbimpl[cmd](...)
    end

    start(function()
    end)
elseif mode == "create" then
    local start = require "server.service.service"
    local cmds = require "server.func.cmd"
    local ldb = require "lgame.leveldb"
    local path = "run/db/" .. skynet.getenv("server_name")
    local pdb = ldb.create(path, 1024 * 1024 * 16)

    local addrs = {}

    cmds.addrs = function()
        return addrs
    end

    cmds.get_pdb = function()
        return pdb
    end

    start(function()
        for i = 1, 5 do
            local addr = skynet.newservice("server/db/db", "child")
            skynet.call(addr, "lua", "set_pdb", pdb)
            table.insert(addrs, addr)
        end
    end)
else
    local cfg = require "server.db.cfg"
    local caddr = skynet.uniqueservice("server/db/db", "create")
    local addrs = skynet.call(caddr, "lua", "addrs")
    local pdb = skynet.call(caddr, "lua", "get_pdb")

    local M = {}

    local read_cmds = cfg.read_cmds
    local write_cmds = cfg.write_cmds
    local IDX = 2
    M.ope = function(cmd, ...)
        if write_cmds[cmd] then
            skynet.send(addrs[1], "lua", "ope", cmd, ...)
        elseif read_cmds[cmd] then
            local addr = addrs[IDX]
            local ret = skynet.call(addr, "lua", "ope", cmd, ...)
            IDX = IDX + 1
            if IDX > #addrs then
                IDX = 2
            end
            return ret
        else
            print("db ope err", cmd, ...)
        end
    end

    M.get_pdb = function()
        return pdb
    end

    return M
end
