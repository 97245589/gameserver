local print, string = print, string

local skynet = require "skynet"
local socket = require "skynet.socket"
local lkcp = require "lkcp"

local function server()
    local host, kcp
    host = socket.udp(function(str, from)
        if not kcp then
            kcp = lkcp.create_lkcp(1, host, from)
        end

        kcp:netpack_input(str)
        print(kcp:netpack_pop());
    end, "127.0.0.1", 8765)

end

local function client()
    local host
    host = socket.udp(function(str, from)
        print("client recv", str, from)
    end)
    socket.udp_connect(host, "127.0.0.1", 8765)
    local kcp_cli = lkcp.lkcp_client(1, host)
    for i = 1, 20 do
        kcp_cli:send(string.pack('>s2', "hello" .. i))
        kcp_cli:update(i)
    end
end

skynet.start(function()
    skynet.fork(server)
    skynet.fork(client)
end)
