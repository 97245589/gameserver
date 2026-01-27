local require = require
local client = require "server.game.player.client"
local role = require "server.game.player.mgr.role"
local item = require "server.game.player.mgr.item"

local req = client.req

req.get_data = function(player)
    local ret = {
        code = 0
    }
    ret.role = player.role

    return ret
end

req.use_item = function(player, args)
    local itemid = args.itemid
    local num = args.num

    item.use_item(player, itemid, num)
    return {
        code = 0
    }
end

return req
