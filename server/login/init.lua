local require = require
local skynet = require "skynet"
local config = require "common.service.service_config"

skynet.start(function()
    skynet.newservice("server/login/logind/logind")
    for i = 1, config.service_num.login_child do
        local service_name = "login" .. i
        skynet.newservice("server/login/child/start", service_name)
    end
    skynet.newservice("server/login/cluster/start", "cluster")
    skynet.exit()
end)
