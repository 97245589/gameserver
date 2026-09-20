local start = require "server.service.service"
local skynet = require "skynet"
local cluster = require "skynet.cluster"
local cmds = require "server.func.cmd"

local server_name = skynet.getenv("server_name")
local myid = tonumber(skynet.getenv("server_id"))
local mygroupid = myid // 10

local master
local sc

local group_master = {}
local groups = {}

local parse_servername = function(name)
    local c2 = string.sub(name, 1, 2)
    if "db" ~= c2 then
        return
    end
    local id = tonumber(string.sub(3, -1))
    return id, id // 10
end

local mygroup_names = function()
    local mygroup = groups[mygroupid]
    local arr = {}
    for k in pairs(mygroup) do
        table.insert(arr, k)
    end
    table.sort(arr)
    if arr[1] ~= server_name then
        return
    end
    return arr
end

local notify_master = function(dbs)
    if not master then
        return
    end
    local names = mygroup_names()
    if not names then
        return
    end
    for _, name in ipairs(dbs) do
        cluster.send(name, "init", "notify_master", mygroupid, master)
    end
end

local select_master = function()
    if master then
        return
    end
    local names = mygroup_names()
    if not names then
        return
    end
    if #names == 1 then
        master = server_name
    else
        master = server_name
        for _, name in ipairs(names) do
        end
    end

    for g, gnames in pairs(groups) do
        for name in pairs(gnames) do
            cluster.send(name, "init", "notify_master", mygroupid, master)
        end
    end
end

local add_db_servers = function(servers)
    local dbs = {}
    for name in pairs(servers) do
        local id, group = parse_servername(name)
        if not id then
            goto cont
        end
        -- if group == mygroupid then
        --     master = nil
        -- end
        table.insert(dbs, name)
        groups[group] = groups[group] or {}
        groups[group][name] = 1
        ::cont::
    end
    notify_master(dbs)
end

local del_db_servers = function(servers)
    for name in pairs(servers) do
        local id, group = parse_servername(name)
        if not id then
            goto cont
        end
        local ginfo = groups[group]
        ginfo[name] = nil
        if name == master then
            master = nil
        end
        if not next(ginfo) then
            print("no group!!!", group)
        end
        ::cont::
    end
end

local init_cluster = function()
    sc = require "server.service.cluster"
    groups[mygroupid] = { [server_name] = 1 }

    sc.set_diff_cb(function(upd, del)
        add_db_servers(upd)
        del_db_servers(del)
        print("dbservers info:", dump(groups))
        select_master()
    end)
end

start(function()
    skynet.newservice("server/db/mgr")
    skynet.newservice("server/db/sync")
    init_cluster()
end, "init")

cmds.notify_master = function(group, server)
    group_master[group] = server
    if group == mygroupid then
        master = server
    end
    print("notify master", group, server)
end
