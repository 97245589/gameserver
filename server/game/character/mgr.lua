local M = {}
local characters = {}

M.get_character = function(cid)
    local character = characters[cid]
    if character then
        return character
    end
    character = {}
    characters[cid] = character
    return character
end

return M
