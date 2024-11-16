local skynet = require "skynet"
local zstd = require "common.tool.zstd"
local mgrs = require "server.game.player_mgr.mgrs"

local db_data = {}

local save_db = function()
    local bin = zstd.pack(db_data)
    -- db:hset("server_data", "data", bin)
end

skynet.fork(function()
    while true do
        skynet.sleep(100)
        save_db()
        mgrs.all_tick()
    end
end)

return {
    db_data = db_data
}
