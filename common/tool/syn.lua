local type, setmetatable = type, setmetatable
local table, pairs, next = table, pairs, next
local tmove, tinsert = table.move, table.insert

local path_cache = {
    [''] = {}
}

local create_path = function(parent_path, name)
    if not parent_path then
        return ""
    end

    local newpath
    if type(name) == "number" then
        newpath = parent_path .. '|' .. name
    elseif type(name) == "string" then
        newpath = parent_path .. "|'" .. name
    end
    if path_cache[newpath] then
        return newpath
    end

    local patharr = path_cache[parent_path]
    local arr = {}
    tmove(patharr, 1, #patharr, 1, arr)
    tinsert(arr, name)
    path_cache[newpath] = arr
    return newpath
end

local fill_dirty_obj = function(obj, dirty_obj, patharr)
    for i = 1, #patharr do
        local nk = patharr[i]
        if not dirty_obj[nk] then
            local objnid = obj[nk].id
            if objnid == nk then
                dirty_obj[nk] = {
                    id = objnid
                }
            else
                dirty_obj[nk] = {}
            end
        end
        obj = obj[nk]
        dirty_obj = dirty_obj[nk]
    end
    return dirty_obj, obj
end
local player_dirty_delete = function(dirtys, id, patharr, k)
    local deletes = dirtys.deletes
    local objs = dirtys.objs
    if not deletes[id] then
        deletes[id] = {}
    end
    local delete_obj, obj = fill_dirty_obj(objs[id], deletes[id], patharr)
    delete_obj[k] = {
        id = k
    }
end
local player_dirty_update = function(dirtys, id, patharr, k, v)
    local updates = dirtys.updates
    local objs = dirtys.objs
    if not updates[id] then
        updates[id] = {}
    end
    local update_obj = fill_dirty_obj(objs[id], updates[id], patharr)
    if type(v) == 'table' then
        update_obj[k] = v.__INFO
    else
        update_obj[k] = v
    end
end
local newindexcb = function(dirtys, id, path, k, v)
    if not dirtys.updates then
        dirtys.updates = {}
    end
    if not dirtys.deletes then
        dirtys.deletes = {}
    end
    local patharr = path_cache[path]
    if v == nil then
        player_dirty_delete(dirtys, id, patharr, k)
    else
        player_dirty_update(dirtys, id, patharr, k, v)
    end
end

local M = {}
M.create_obj_syn = function(dirtys)
    local m = {}
    local MT = {
        __index = function(tb, k)
            local info = tb.__INFO
            local val = info[k]
            if "table" == type(val) and not val.__INFO then
                info[k] = m.create_syn(val, tb.__ID, tb.__PATH, k)
            end
            return info[k]
        end,
        __newindex = function(tb, k, v)
            local info = tb.__INFO
            local old_v = info[k]
            if type(v) == "table" and not v.__INFO then
                v = m.create_syn(v, tb.__ID, tb.__PATH, k)
            end
            info[k] = v
            newindexcb(dirtys, tb.__ID, tb.__PATH, k, v)
        end,
        __pairs = function(tb)
            return next, tb.__INFO, nil
        end
    }
    m.create_syn = function(obj, id, parent_path, name)
        if obj.__INFO then
            return obj
        end

        local new_obj = {
            __INFO = obj,
            __PATH = create_path(parent_path, name),
            __ID = id
        }
        return setmetatable(new_obj, MT)
    end
    return m
end

return M
