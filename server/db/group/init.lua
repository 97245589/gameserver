local start = require "server.service.service"

start(function()
    require "server.db.group.group"
end, "group")
