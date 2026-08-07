local client = require "server.game.character.client"
local req = client.req

req.req_test = function(character, args)
    print("=== req test", dump(args))
    client.push(character.id, "push_test", { push = "push_test" })
    return { code = 100 }
end
