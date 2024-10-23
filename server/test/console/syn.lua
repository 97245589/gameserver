require "common.tool.lua_tool"
local type, print, print_v, clone, dump, getmetatable = type, print, print_v, clone, dump, getmetatable
local table, next, pairs = table, next, pairs
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

local players = {}
local players_dirty = {
    updates = nil,
    deletes = nil,
    objs = players
}

local handle_dirty
handle_dirty = function(tb)
    for k, v in pairs(tb) do
        if type(v) == "table" then
            tb[k] = handle_dirty(v)
        end
    end
    if next(tb) then
        return tb
    else
        return nil
    end
end

local tick_players_dirty = function()
    players_dirty.objs = nil
    handle_dirty(players_dirty)
    print_v(players_dirty)

    players_dirty.objs = players
    players_dirty.updates = nil
    players_dirty.deletes = nil
end

local player_syn = syn.create_obj_syn(players_dirty)

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

    player = player_syn.create_syn(player, 1000)
    players[1000] = player
    player.role.name = 'hello world'
    player.item[1000].num = 10
    player.item[2000] = {
        id = 2000,
        num = 200
    }
    player.item[1000] = nil
    tick_players_dirty()
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
end

skynet.start(function()
    test()
    -- test1()
    skynet.exit()
end)
