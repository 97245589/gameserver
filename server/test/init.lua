local require, tostring = require, tostring
local skynet = require "skynet"
local socket = require "skynet.socket"

local prefix = "server/test/test"

skynet.start(function()
    local stdin = socket.stdin()
    local cmdline = socket.readline(stdin, "\n")
    skynet.newservice(prefix .. "/" .. cmdline)
    skynet.exit()
end)
