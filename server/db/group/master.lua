local skynet = require "skynet"
local cluster = require "skynet.cluster"
local version = require "server.db.group.version"

local server_name = skynet.getenv("server_name")
local myid = tonumber(skynet.getenv("server_id"))
local mygroupid = myid // 10

local master
local group_master = {}
local groups = {
    [mygroupid] = { [server_name] = 1 }
}

local parse_servername = function(name)
    local c2 = string.sub(name, 1, 2)
    if "db" ~= c2 then
        return
    end
    local id = tonumber(string.sub(3, -1))
    return id, id // 10
end

local mygroup_servers = function()
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

local send_master = function(name)
    if name == server_name then
        return
    end
    cluster.send(name, "group", "group_master", mygroupid, master)
end
local notify_master = function(upd)
    if not master then
        return
    end
    local servers = mygroup_servers()
    if not servers then
        return
    end
    for _, name in ipairs(servers) do
        send_master(name)
    end
end

local select_master = function()
    if master then
        return
    end
    local servers = mygroup_servers()
    if not servers then
        return
    end
    if 1 == #servers then
        master = server_name
    else
        local vs = {}
        vs[1] = version.get_version()
        for i = 2, #servers do
            local server = servers[i]
            vs[i] = cluster.call(server, "group", "get_version")
        end

        local min = math.maxinteger
        local midx
        for i = 1, #servers do
            if min > vs[i] then
                min = vs[i]
                midx = i
            end
        end
        master = servers[midx]
    end

    for gid, gservers in pairs(groups) do
        for name in pairs(gservers) do
            send_master(name)
        end
    end
end

local add_db_servers = function(servers)
    local dservers = {}
    for name in pairs(servers) do
        local id, group = parse_servername(name)
        if not id then
            goto cont
        end
        if group == mygroupid then
            master = nil
        end
        table.insert(dservers, name)
        groups[group] = groups[group] or {}
        groups[group][name] = 1
        ::cont::
    end
    notify_master(dservers)
end

local del_db_servers = function(servers)
    for name in pairs(servers) do
        local id, group = parse_servername(name)
        if not id then
            goto cont
        end
        if name == master then
            master = nil
        end
        local gservers = groups[group]
        gservers[name] = nil
        if not next(gservers) then
            print("err no group!!!", group)
        end

        ::cont::
    end
end

local M = {}

M.cluster_diff = function(upd, del)
    add_db_servers(upd)
    del_db_servers(del)
    print("dbserves groups:", dump(groups))
    select_master()
end

M.group_master = function(group, sname)
    group_master[group] = sname
    if group == mygroupid then
        master = sname
    end
    print("group master", group, sname, server_name)
end

M.master_bygroup = function(group)
    if group == mygroupid and master == server_name then
        return true
    end
    return false, group_master[group]
end

return M
