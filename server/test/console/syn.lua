require "common.tool.lua_tool"
local type, print, print_v, clone, dump, getmetatable = type, print, print_v, clone, dump, getmetatable
local table, pairs = table, pairs
local skynet = require "skynet"
local sproto = require "sproto"
local syn = require "common.tool.syn"

local sp = sproto.parse [[
    .Role {
        id 0 : integer
        name 1: string
    }
    .Item {
        id 0 : integer
        num 1 : integer
    }
    .Player {
        role 0 : Role
        item 1: *Item(id)
    }
]]

local push_update = function(playerid, updateobj)
    print("push_update", playerid, dump(updateobj))
end
local push_delete = function(playerid, deleteobj)
    print("push_delete", playerid, dump(deleteobj))
end
local players = {}
local players_dirty = {
    updates = nil,
    deletes = nil,
    objs = players,
    push_update = push_update,
    push_delete = push_delete
}

local tick_players_dirty = function()
    for playerid, update in pairs(players_dirty.updates) do
        push_update(playerid, update)
    end
    for playerid, delete in pairs(players_dirty.deletes) do
        push_delete(playerid, delete)
    end
    players_dirty.updates = nil
    players_dirty.deletes = nil
end

local player_syn = syn.create_obj_syn(players_dirty)
local player1

local test = function()
    local player = {
        role = {
            id = 1000,
            name = 'hello'
        },
        item = {
            [1000] = {
                id = 1000,
                num = 100
            }
        }
    }
    player1 = clone(player)

    player = player_syn.create_syn(player, 1000)
    players[1000] = player
    player.role.name = 'hello world'
    player.item[1000].num = 10
    player.item[2000] = {
        id = 2000,
        num = 200
    }
    player.item[1000] = nil
    print_v(players_dirty.updates, "updates")
    print_v(players_dirty.deletes, "deletes")
end

local test1 = function()
    local fill_update
    fill_update = function(p, update)
        for k, v in pairs(update) do
            if type(v) == "table" and type(p[k]) == "table" then
                fill_update(p[k], v)
            else
                p[k] = v
            end
        end
    end
    local is_delete_ele = function(k, tb)
        if k ~= tb.id then
            return false
        end
        local i = 0
        for k, v in pairs(tb) do
            i = i + 1
            if i > 1 then
                return false
            end
        end
        return true
    end
    local fill_delete
    fill_delete = function(p, delete)
        for k, v in pairs(delete) do
            if is_delete_ele(k, v) then
                p[k] = nil
            else
                fill_delete(p[k], v)
            end
        end
    end
    fill_update(player1, players_dirty.updates[1000])
    print("after fill_update", dump(player1))
    fill_delete(player1, players_dirty.deletes[1000])
    print("after fill_delete", dump(player1))
end

skynet.start(function()
    test()
    test1()
    skynet.exit()
end)
