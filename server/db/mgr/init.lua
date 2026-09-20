local start = require "server.service.service"

start(function()
    require "server.db.mgr.rpc"
end, "mgr")
