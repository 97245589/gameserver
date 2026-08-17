local mod = require "server.game.character.mod"

local M = {}

M.init = function(character)
    character.role = character.role or {}
    local crole = character.role
    crole.level = 1
end

mod.add_module(M, "role")
return M
