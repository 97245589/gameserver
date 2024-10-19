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

local test = function()
    local players = {}
    local players_dirty = {
        dirtys = nil,
        deletes = nil,
        objs = players
    }
    local tick_players_dirty = function()
        for playerid, dirty in pairs(players_dirty.dirtys) do
            local bin = sp:pencode("Player", dirty)
            print("tick dirty", playerid, dump(sp:pdecode("Player", bin)))
        end
        players_dirty.dirtys = nil
        players_dirty.deletes = nil
    end

    local player_syn = syn.create_obj_syn(players_dirty)
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
    local player1 = clone(player)

    player = player_syn.create_syn(player, 1000)
    players[1000] = player
    player.role.name = 'hello world'
    player.item[1000].num = 10
    player.item[2000] = {
        id = 2000,
        num = 200
    }
    print_v(players_dirty.dirtys)

    local fill_update_data
    fill_update_data = function(obj, upd)
        for k, v in pairs(upd) do
            if type(v) == "table" and type(obj[k]) == "table" then
                fill_update_data(obj[k], v)
            else
                obj[k] = v
            end
        end
    end
    fill_update_data(player1, players_dirty.dirtys[1000])
    print_v(player1)
    -- print_v(player)
    local p = skynet.unpack(skynet.packstring(player))
    print("seri p metatable", getmetatable(p), getmetatable(player))
    local bin = sp:pencode("Player", player)
    p = sp:pdecode("Player", bin)
    print("sproto seri", getmetatable(p), dump(p))

    tick_players_dirty()
end

skynet.start(function()
    test()
    skynet.exit()
end)
