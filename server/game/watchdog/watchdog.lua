local require, string, print = require, string, print
local skynet = require "skynet"

local addr = skynet.newservice("server/game/watchdog/handle", "child")
local watchdog = require "common.service.watchdog"

local close_conn = watchdog.close_conn

watchdog.set_data_handle(function(fd, msg, gate)
    skynet.send(addr, "lua", "data", fd, msg, gate)
end)
watchdog.set_socket_cb({
    close_cb = function(fd)
        skynet.send(addr, "lua", "close", fd)
    end
})
watchdog.start()
