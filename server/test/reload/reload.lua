local print, dump, require = print, dump, require
local skynet = require "skynet"
local socket = require "skynet.socket"
local cmds = require "common.service.cmds"
local config_load = require "common.service.config_load"

local loop = function()
    local stdin = socket.stdin()
    while true do
        local cmdline = socket.readline(stdin, "\n")
        cmds.hotreload()
        print("config test", dump(config_load.excel_config("item")))
    end
end

skynet.fork(loop)
