local require = require
require "common.func.tool"
local skynet = require "skynet"

local rank = function()
    local lrank = require "lgame.rank"
end

local zstd = function()
    local zstd = require "common.func.zstd"
end

local cfg = function()
    local cfg = require "common.func.cfg"
    while true do
        skynet.sleep(100)
        print(dump(cfg.get("item")))
        cfg.reload("item")
    end
end

local ip = function()
    local ip = require "common.func.ip"
    print(ip.private())
    print(ip.public())
end

skynet.start(function()
    ip()
end)
