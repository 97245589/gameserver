local skynet = require "skynet"
local ldbslot = require "lgame.dbslot"

local SERVERID = tonumber(skynet.getenv("server_id"))
local GROUP = SERVERID // 10

local M = {}
M.SLOT_NUM = 1000

local slot_arr = {}

M.slot_group = {
    [300] = 1,
    [600] = 2,
}

local create_slot = function(slot_group)
    local core = ldbslot.create(slot_group)
    return {
        find_group = function(slot)
            return core:find(slot)
        end
    }
end

return M
