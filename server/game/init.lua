local skynet = require "skynet"

skynet.start(function ()
    skynet.newservice("server/game/game/init")
    skynet.exit()
end)