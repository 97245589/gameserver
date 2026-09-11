local skynet = require "skynet"
local ldb = require "server.func.ldb"
local timerf = require "server.func.timer"
local time = require "server.game.common.time"

local M = {}
M.dbinfo = {}

local init_db = function()
    local dbinfo = {}
    dbinfo.server_open_time = dbinfo.server_open_time or time.day_start()
    time.set_open_time(dbinfo.server_open_time)
    --[[
    local bin = ldb.call("hget", "game", "info")
    if bin then
        dbinfo = skynet.unpack(bin)
    end
    ]]
    M.dbinfo = dbinfo
end
init_db()

local modules = {}
M.add_module = function(mod, name)
    if modules[name] then
        print("add module err", name)
        return
    end
    modules[name] = mod
end

local timer_func = {}
local timer = timerf(function(id, cmd, ...)
    local func = timer_func[cmd]
    func(...)
end)
M.add_timer = function(tm, cmd, ...)
    timer.add(0, tm, cmd, ...)
end
M.add_timer_func = function(cmd, func)
    timer_func[cmd] = func
end

local save_data = function()
    local bin = skynet.packstring(M.dbinfo)
    -- ldb.send("hset", "game", "info", bin)
end
skynet.fork(function()
    local lastup = os.time()
    while true do
        skynet.sleep(100)
        local ok, err = pcall(function()
            local tm = os.time()
            timer.expire(tm)
            if tm - lastup > 20 then
                save_data()
                lastup = tm
            end
        end)
        if not ok then
            print("tick err", err)
        end
    end
end)

return M
