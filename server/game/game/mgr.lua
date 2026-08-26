local skynet = require "skynet"
local ldb = require "server.func.ldb"
local timerf = require "server.func.timer"
local msgpack = require "lgame.msgpack"
local msgpack_core = msgpack.create(1024 * 500)

local M = {}
M.dbinfo = {}

local init_db = function()
    local dbinfo = {}
    -- local bin = ldb.call("hget", "game", "info")
    -- if bin then
    --     dbinfo = msgpack.decode(bin)
    -- end
    M.dbinfo = dbinfo
end
local save_data = function()
    -- ldb.send("hset", "game", "info", msgpack_core:encode(M.dbinfo))
end

local timer_func = {}
local timer = timerf(function(id, cmd, ...)
    local func = timer_func[cmd]
    func(...)
end)
M.add_timer = function(tm, cmd, ...)
    timer.add(0, tm, cmd, ...)
end
M.add_timer_func = function(tp, func)
    timer_func[tp] = func
end

skynet.fork(function()
    while true do
        skynet.sleep(100)
        local ok, err = pcall(function()
            local tm = os.time()
            timer.expire(tm)
            save_data()
        end)
        if not ok then
            print("tick err", err)
        end
    end
end)

return M
