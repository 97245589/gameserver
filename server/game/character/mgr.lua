local skynet = require "skynet"
local squeue = require "skynet.queue"
local ldb = require "server.func.ldb"
local mod = require "server.game.character.mod"
local toolf = require "server.func.tool"
local timerf = require "server.func.timer"
local msgpack = require "lgame.msgpack"
local msgpack_core = msgpack.create(1024 * 500)

local M = { kick = nil }
local characters = {}

local cs = squeue()
M.get_character = function(cid)
    local character = characters[cid]
    if not character then
        cs(function()
            character = characters[cid]
            if not character then
                -- local bin = ldb.call("hget", "character", cid)
                -- character = msgpack.decode(bin)
                character = {}
                mod.init_character(character)
                characters[cid] = character
            end
        end)
    end
    character.id = cid
    character.tm = os.time()
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
local tick_save = function()
    if not next(db_cids) then
        db_cids = toolf.keys(characters, 1)
    end
    local tm = os.time()
    local i = 1
    for cid, _ in pairs(db_cids) do
        local character = characters[cid]
        -- ldb.send("hset", "character", cid, msgpack_core:encode(character))
        if tm >= character.tm + 10 then
            M.kick(cid)
            characters[cid] = nil
        end

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
        local ok, err = pcall(function()
            local n = os.time()
            tick_save()
            timer.expire(n)
        end)
        if not ok then
            print("tick err", err)
        end
    end
end)

return M
