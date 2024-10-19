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

local player_dirty_delete = function()
end
local player_dirty_update = function(dirtys, id, patharr, k, v, objs)
    if not dirtys[id] then
        dirtys[id] = {}
    end
    local obj = objs[id]
    local dirty_obj = dirtys[id]
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
    if type(v) == 'table' then
        dirty_obj[k] = v.__INFO
    else
        dirty_obj[k] = v
    end
end
local newindexcb = function(obj, id, path, k, v)
    if not obj.dirtys then
        obj.dirtys = {}
    end
    if not obj.deletes then
        obj.deletes = {}
    end
    local patharr = path_cache[path]
    if v == nil then
        player_dirty_delete(obj.deletes, id, patharr, k)
    else
        player_dirty_update(obj.dirtys, id, patharr, k, v, obj.objs)
    end
end

local M = {}
M.create_obj_syn = function(obj)
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
            newindexcb(obj, tb.__ID, tb.__PATH, k, v)
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
