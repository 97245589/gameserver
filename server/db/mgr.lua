local skynet = require "skynet"
local start = require "server.service.service"
local ldb = require "lgame.leveldb"
local cmds = require "server.func.cmd"

local waddr
local raddrs = {}
local idx = 1

local rcmds = {
    hget = 1,
    hmget = 1,
    hgetall = 1,
    scan = 1,
    hscan = 1,
    keys = 1
}
local wcmds = {
    hset = 1,
    hmset = 1,
    hdel = 1,
    del = 1
}
cmds.ope = function(cmd, ...)
    if rcmds[cmd] then
        idx = idx + 1
        if idx > #raddrs then
            idx = 1
        end
        return skynet.call(raddrs[idx], "lua", "ope", cmd, ...)
    elseif wcmds[cmd] then
        skynet.send(waddr, "lua", "ope", cmd, ...)
        return true
    else
        print("db cmd not found", cmd, ...)
    end
end

start(function()
    local path = "run/db/" .. skynet.getenv("server_mark")
    local pdb = ldb.create(path, 8 * 1024 * 1024)

    waddr = skynet.newservice("server/db/service")
    skynet.send(waddr, "lua", "set_pdb", pdb)
    for i = 1, 3 do
        local addr = skynet.newservice("server/db/service")
        table.insert(raddrs, addr)
        skynet.send(addr, "lua", "set_pdb", pdb)
    end
end, "mgr")
