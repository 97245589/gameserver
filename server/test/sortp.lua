local skynet = require "skynet"
require "skynet.manager"
require "server.func.print"

local sort_sp = function()
    local string = string
    local fname = "server/config/proto/game.sproto"
    local arr = {}

    local idx = 1
    local regex = "^%s*(%S+)%s+(%d+)"
    for l in io.lines(fname) do
        local line = l .. '\n'
        local p = string.find(line, ":")
        if p then
            goto cont
        end
        if line:match(regex) then
            line = line:gsub("%d+", idx)
            idx = idx + 1
        end
        ::cont::
        table.insert(arr, line)
    end

    local f = io.open(fname, "w")
    f:write(table.concat(arr))
    f:close()
end

skynet.start(function()
    sort_sp()
    skynet.abort()
end)
