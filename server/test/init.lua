local skynet = require "skynet"

skynet.start(function ()
    skynet.newservice("server/test/test")
    skynet.exit()
end)