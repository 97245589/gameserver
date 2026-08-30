local start = require "server.service.service"

start(function()
    local sc = require "server.service.cluster"
end, "cluster")
