local skynet = require "skynet"
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

    print(table.concat(arr))
end

skynet.start(function()
    sort_sp()
end)
