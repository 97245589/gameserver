local enum = require "server.game.common.enum"

local create_quest_mgr = function(handler)
    local M = {}

    local count = function(obj, quest, cfg_target, addnum)
        local bnum = quest.num
        local ttype = cfg_target[1]
        if handler[ttype] then
            quest.num = handler[ttype](obj, cfg_target, quest) or 0
        else
            quest.num = quest.num + addnum
        end

        local tnum = cfg_target[#cfg_target]
        if quest.num >= tnum then
            quest.num = tnum
            quest.status = enum.quest_finish
        end

        if bnum ~= quest.num then
            return true
        end
    end

    M.init_quests = function(obj, qobj, cfgs)
        qobj.index = qobj.index or {}
        qobj.quests = qobj.quests or {}
        local quests = qobj.quests
        local index = qobj.index

        for qid, cfg in pairs(cfgs) do
            if quests[qid] then
                goto cont
            end
            local cfg_target = cfg.target
            local quest = {
                id = qid, num = 0, status = enum.quest_unfinish
            }
            count(obj, quest, cfg_target, 0)
            if quest.status == enum.quest_unfinish then
                local ttype = cfg_target[1]
                index[ttype] = index[ttype] or {}
                index[ttype][qid] = 1
            end
            quests[qid] = quest
            ::cont::
        end
    end

    M.count = function(obj, qobj, cfgs, event)
        local index = qobj.index
        local quests = qobj.quests
        local ttype = event[1]
        local idx_qids = index[ttype]
        if not idx_qids or not next(idx_qids) then
            return
        end

        local arr
        local addnum = event[#event]
        for qid, _ in pairs(idx_qids) do
            local quest = quests[qid]
            local cfg_target = cfgs[qid].target
            local c = count(obj, quest, cfg_target, addnum)
            if quest.status ~= enum.quest_unfinish then
                idx_qids[qid] = nil
                if not next(idx_qids) then
                    index[ttype] = nil
                end
            end
            if c then
                arr = arr or {}
                table.insert(arr, qid)
            end
        end
        return arr
    end

    local cbs = {}
    M.add_trigger_cb = function(cb, name)
        if cbs[name] then
            print("quest add trigger cb err", name)
            return
        end
        cbs[name] = cb
    end

    M.del_trigger_cb = function(name)
        cbs[name] = nil
    end

    M.trigger = function(obj, event)
        for _, cb in pairs(cbs) do
            cb(obj, event)
        end
    end

    return M
end

return create_quest_mgr
