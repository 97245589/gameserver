local mgr = require "server.game.game.mgr"
local enum = require "server.game.common.enum"
local time = require "server.game.common.time"
local config = require "server.game.common.config"

local event_config = {
    [100] = { time = { afteropen_period = {}, duration = { day = 2 } } },
}

local dbinfo = mgr.dbinfo
dbinfo.gevent = dbinfo.gevent or {
    open = {},
    data = {}
}
local gevent = dbinfo.gevent

local impl = {}

local add_timer = function(tm, opt, eid)
    mgr.timer.add(0, tm, enum.timer_gevent, opt, eid)
end

local handler = {
    [enum.event_open] = function(eid)
        local eopen = gevent.open
        local start_tm, end_tm = time.parse(event_config[eid].time)
        print("game event open", eid, time.format(start_tm), time.format(end_tm))
        eopen[eid] = {
            id = eid,
            start_tm = start_tm,
            end_tm = end_tm
        }
        add_timer(end_tm, enum.event_close, eid)
        local impl_event = impl[eid]
        if impl_event and impl_event.open then
            impl_event.open()
        end
    end,
    [enum.event_close] = function(eid)
        local eopen = gevent.open
        local info = eopen[eid]
        print("event close", eid, time.format(info.start_tm), time.format(info.end_ts))
        eopen[eid] = nil
        local start_tm = time.parse(event_config[eid].time)
        if start_tm then
            add_timer(start_tm, enum.event_open, eid)
        end
    end
}
mgr.set_timer_handler(enum.timer_gevent, function(opt, eid)
    handler[opt](eid)
end)

local init = function()
    local eopen = gevent.open
    for eid, info in pairs(eopen) do
        if not event_config[eopen] then
            eopen[eid] = nil
            goto cont
        end
        add_timer(info.end_tm, enum.event_close, eid)
        ::cont::
    end
    for eid, c in pairs(event_config) do
        if eopen[eid] then
            goto cont
        end
        local start_tm = time.parse(c.time)
        if start_tm then
            add_timer(start_tm, enum.event_open, eid)
        end
        ::cont::
    end
end
init()
