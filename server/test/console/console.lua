local skynet = require "skynet"
local socket = require "skynet.socket"

local prefix = "server/test/console"

local loop = function()
    local stdin = socket.stdin()
    while true do
        local cmdline = socket.readline(stdin, "\n")
        if cmdline ~= "" then
            skynet.newservice(prefix .. "/" .. cmdline)
        end
    end
end

skynet.start(function()
    skynet.fork(loop)
end)
