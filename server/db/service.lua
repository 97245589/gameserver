local start = require "server.service.service"
local cmds = require "server.func.cmd"
local dbimpl = require "server.func.dbimpl"

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
