local require, print = require, print
local client_req = require "server.game.player.client_req"
local req = client_req.cli_req

req.push_test = function(player, args)
    -- print("push test")
    client_req.push(player, "push_test", {
        test = os.time()
    })
    return {
        code = 0
    }
end
