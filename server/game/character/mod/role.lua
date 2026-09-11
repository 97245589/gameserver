local mgr = require "server.game.character.mgr"
local config = require "server.game.common.config"

local config_item = config.get("item")

local M = {}

M.load = function()
end

M.init_data = function(character)
    character.role = character.role or {}
    local crole = character.role
    crole.level = 1
end

mgr.add_module(M, "role")
return M
