local mgr = require "server.game.game.mgr"
local enum = require "server.game.common.enum"

local dbinfo = mgr.dbinfo
dbinfo.gevent = dbinfo.gevent or {
    open = {},
    data = {}
}
local gevent = dbinfo.gevent

local add_timer = function(tm, opt, eid)
    mgr.add_timer(tm, enum.timer_gevent, opt, eid)
end
mgr.add_timer_func(enum.timer_gevent, function(opt, eid)

end)


local impl = {}

local init = function()
    local nowts = os.time()
    local eopen = gevent.open
    for eid, info in pairs(eopen) do
        add_timer(info.end_tm, enum.event_close, eid)
    end
end
init()

return {
    impl = impl,
    get_gevent = function()
        return gevent
    end
}
