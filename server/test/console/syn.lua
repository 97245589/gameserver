require "common.tool.lua_tool"
local type, print, print_v, clone, dump, getmetatable = type, print, print_v, clone, dump, getmetatable
local table, next, pairs, ipairs = table, next, pairs, ipairs
local skynet = require "skynet"
local sproto = require "sproto"
local syn = require "common.tool.syn"

local players_dirty
local add_push = function(id, info, mark)
    local pushs = players_dirty.pushs
    if not pushs[id] then
        pushs[id] = {}
    end
    table.insert(pushs[id], {
        mark = mark,
        info = info
    })
end
local players = {}
players_dirty = {
    updates = {},
    deletes = {},
    pushs = {},
    objs = players,
    add_push = add_push
}

local tick_players_dirty = function()
    if players_dirty.updates then
        for id, update in pairs(players_dirty.updates) do
            add_push(id, update, 1)
        end
    end
    if players_dirty.deletes then
        for id, delete in pairs(players_dirty.deletes) do
            add_push(id, delete, 2)
        end
    end
    players_dirty.updates = {}
    players_dirty.deletes = {}
    local ret = players_dirty.pushs
    players_dirty.pushs = {}
    return ret
end

local player_syn = syn.create_obj_syn(players_dirty)

local test = function()
    local player = {}
    player = player_syn.create_syn(player, 1000)
    players[1000] = player

    player.map = {
        [100] = {
            id = 100,
            map = {
                [100] = {
                    id = 100
                },
                [200] = {
                    id = 200
                }
            }
        }
    }
    player.map[100].map[200].num = 200
    player.map[100].map[200] = nil
    print_v(tick_players_dirty())
end

local test1 = function()
    local fill_update
    fill_update = function(p, update)
        for k, v in pairs(update) do
            if type(v) == "table" and type(p[k]) == "table" and next(v) then
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
    local fill_push = function(player, arr)
        for _, push in ipairs(arr) do
            if 1 == push.mark then
                fill_update(player, push.info)
            else
                fill_delete(player, push.info)
            end
        end
    end

    local player = {
        id = 1
    }
    local player1 = clone(player)
    player = player_syn.create_syn(player, 1)
    players[1] = player
    player.role = {
        id = 1,
        name = "hello"
    }
    player.item = {
        [1001] = {
            id = 1001,
            num = 100
        }
    }
    fill_push(player1, tick_players_dirty()[1])
    print_v(player1)
    player.item[1001] = nil
    fill_push(player1, tick_players_dirty()[1])
    print_v(player1)
end

skynet.start(function()
    -- test()
    test1()
    skynet.exit()
end)
