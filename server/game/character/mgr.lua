local skynet = require "skynet"
local db = require "server.func.ldb"
local mod = require "server.game.character.mod"
local toolf = require "server.func.tool"
local timerf = require "server.func.timer"
local msgpack = require "lgame.msgpack"

local M = {}
local characters = {}

M.get_character = function(cid)
    local character = characters[cid]
    if character then
        return character
    end
    character = {}
    mod.init_character(character)
    characters[cid] = character
    return character
end

local timer_func = {}
local timer = timerf(function(id, cmd, ...)
    local character = characters[id]
    if not character then
        return
    end
    local f = timer_func[cmd]
    if not f then
        return
    end
    f(character, ...)
end)
M.add_timer = function(character, tm, cmd, ...)
    timer.add(character.id, tm, cmd, ...)
end
M.add_timer_func = function(fid, func)
    timer_func[fid] = func
end

M.character_leave = function(id)
    characters[id] = nil
    timer.delid(id)
end

local db_cids = {}
local tick_db = function()
    if not next(db_cids) then
        db_cids = toolf.keys(characters, 1)
    end
    local i = 1
    for cid, _ in pairs(db_cids) do
        local character = characters[cid]

        db_cids[cid] = nil
        i = i + 1
        if i >= 10 then
            return
        end
    end
end

skynet.fork(function()
    while true do
        skynet.sleep(100)
        pcall(function()
            local n = os.time()
            tick_db()
            timer.expire(n)
        end)
    end
end)

return M
