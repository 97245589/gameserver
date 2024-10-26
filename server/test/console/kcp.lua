local print, string, os = print, string, os

local skynet = require "skynet"
local socket = require "skynet.socket"
local lkcp = require "lkcp"

local function server()
    local host, kcp
    local i = 0
    host = socket.udp(function(str, from)
        if not kcp then
            kcp = lkcp.create_lkcp(1, host, from)
        end
        kcp:netpack_input(str)
        print(kcp:netpack_pop())
        kcp:update(i)
        i = i + 1
    end, "127.0.0.1", 8765)

end

local function client()
    local host, kcp_cli
    host = socket.udp(function(str, from)
        -- print("client recv", str, from)
        kcp_cli:netpack_input(str)
        kcp_cli:netpack_pop()
    end)
    socket.udp_connect(host, "127.0.0.1", 8765)
    kcp_cli = lkcp.lkcp_client(1, host)
    for i = 1, 1000 do
        skynet.sleep(1)
        kcp_cli:send(string.pack('>s2', "hello" .. i))
        kcp_cli:update(i)
    end
end

skynet.start(function()
    skynet.fork(server)
    skynet.fork(client)
end)
