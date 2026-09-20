local start = require "server.service.service"

start(function()
    require "server.db.proxy.proxy"
end, "proxy")
