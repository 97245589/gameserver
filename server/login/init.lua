local require = require
local skynet = require "skynet"
local config = require "common.service.service_config"

skynet.start(function()
    skynet.newservice("server/login/login/start", "login")
    skynet.exit()
end)
