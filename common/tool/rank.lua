local require, os, pairs, print, tostring = require, os, pairs, print, tostring
local print_v = print_v
local lrank = require "lutil.lrank"

local rank_events = {}

local mgr = {}

mgr.create_rank = function(rankid, event, num, db_rank)
    local ret = {
        rankid = rankid,
        event = event
    }
    local rank_core = lrank.create_lrank(num)
    ret.add_rank = function(id, score, time)
        rank_core:add_rank(id, score, time or os.time())
    end
    ret.info = function(num, me_id)
        num = num or 1000
        return rank_core:rank_info(num, me_id)
    end
    ret.dump = function()
        print(rank_core:dump())
    end
    ret.db_data = function()
        return rank_core:db_data()
    end
    ret.close = function()
        print("rank close", rankid)
        if event then
            rank_events[event][rankid] = nil
        end
    end

    if db_rank then
        for i = 1, #db_rank, 3 do
            local id = db_rank[i]
            local score = db_rank[i + 1]
            local time = db_rank[i + 2]
            ret.add_rank(id, score, time)
        end
    end

    if event then
        if not rank_events[event] then
            rank_events[event] = {}
        end
        rank_events[event][rankid] = ret
    end

    return ret
end

mgr.trigger_rank = function(event, id, score)
    local rank_event = rank_events[event]
    if not rank_event then
        return
    end
    for rankid, rank in pairs(rank_event) do
        rank.add_rank(id, score)
    end
end

return mgr
