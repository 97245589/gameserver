local start = require "server.service.service"
local skynet = require "skynet"

local myid = tonumber(skynet.getenv("server_id"))
local groupid = myid // 10

local master
local sc

local group_master = {}
local groups = {}

local parse_servermark = function(mark)
    local c2 = string.sub(mark, 1, 2)
    if "db" ~= c2 then
        return
    end
    local id = tonumber(string.sub(3, -1))
    return id, id // 10
end

local add_db_servers = function(servers)
    for mark in pairs(servers) do
        local id, group = parse_servermark(mark)
        if not id then
            goto cont
        end
        groups[group] = groups[group] or {}
        groups[group][mark] = 1
        ::cont::
    end
end

local del_db_servers = function(servers)
    for mark in pairs(servers) do
        local id, group = parse_servermark(mark)
        if not id then
            goto cont
        end
        local ginfo = groups[group]
        ginfo[mark] = nil
        if not next(ginfo) then
            print("no group!!!", group)
        end
        ::cont::
    end
end

local first_cb = function()
    add_db_servers(sc.get_server_host())
    local mygroup = groups[groupid]
    local marks = {}
    for mark in pairs(mygroup) do
        table.insert(marks, mark)
    end
    table.sort(marks)
end

local init_cluster = function()
    local first_done
    sc = require "server.service.cluster"

    sc.set_diff_cb(function(upd, del)
        if not first_done then
            first_done = true
            first_cb()
        end
        add_db_servers(upd)
        del_db_servers(del)
        print("dbservers info:", dump(groups))
    end)
end

start(function()
    skynet.newservice("server/db/mgr")
    local sync = skynet.newservice("server/db/sync")
    init_cluster()
end, "init")
