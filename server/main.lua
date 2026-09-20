local skynet = require "skynet"

skynet.start(function()
    local debug_console_port = skynet.getenv("debug_console_port")
    if debug_console_port then
        skynet.newservice("debug_console", debug_console_port)
    end

    local server_type = skynet.getenv("server_type")
    local init_service = "server/" .. server_type .. "/init"
    skynet.newservice(init_service)
    skynet.exit()
end)
