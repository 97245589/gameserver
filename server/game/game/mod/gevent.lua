local mgr = require "server.game.game.mgr"

local dbinfo = mgr.dbinfo
dbinfo.gevent = dbinfo.gevent or {}
local gevent = dbinfo.gevent

local impl = {}

local init = function()
end

return {
    impl = impl
}
