local skynet = require "skynet"

skynet.start(function ()
    print("test init ===")
    skynet.newservice("server/test/rank")
    skynet.exit()
end)