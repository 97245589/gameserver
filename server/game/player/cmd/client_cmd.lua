local require, print = require, print
local client_req = require "server.game.player.client_req"
local cli_cmds = client_req.client_cmds

cli_cmds.push_test = function(player, args)
    client_req.push(player, "push_test", {
        test = os.time()
    })
    return {
        code = 0
    }
end
