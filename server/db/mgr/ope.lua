local mode = ...
local skynet = require "skynet"
local ldb = require "lgame.leveldb"

if mode == "child" then
    local start = require "server.service.service"
    local dbimpl = require "server.func.dbimpl"
    local cmds = require "server.func.cmd"

    cmds.set_pdb = function(pdb)
        dbimpl.set_pdb(pdb)
    end

    cmds.ope = function(cmd, ...)
        local f = dbimpl[cmd]
        if not f then
            print("db ope err", cmd, ...)
            return
        end
        return f(...)
    end

    start(function()
    end)
else
    local cfg = require "server.db.cfg"
    local M = {}
    local addrs = {}

    local path = "run/db/" .. skynet.getenv("server_name")
    local pdb = ldb.create(path, 1024 * 1024 * 8)

    for i = 1, 3 do
        local addr = skynet.newservice("server/db/mgr/ope", "child")
        table.insert(addrs, addr)
        skynet.send(addr, "lua", "set_pdb", pdb)
    end

    local IDX = 2
    local read_cmds = cfg.read_cmds
    local write_cmds = cfg.write_cmds
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
            print("ope err", cmd, ...)
            return
        end
    end

    M.get_pdb = function()
        return pdb
    end

    return M
end
