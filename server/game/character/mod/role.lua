local mod = require "server.game.character.mod"

local M = {}

M.init_mod = function()
end

M.init_data = function(character)
    character.role = character.role or {}
    local crole = character.role
    crole.level = 1
end

mod.add_module(M, "role")
return M
