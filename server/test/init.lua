local skynet = require "skynet"

skynet.start(function()
    skynet.newservice("server/test/" .. skynet.getenv("param"))
    skynet.exit()
end)
