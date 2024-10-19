local require, table, print = require, table, print
require "common.tool.lua_tool"
local skynet = require "skynet"
local socket = require "skynet.socket"

local MODE_FOLLOWER = ...

-- print("---------- logind", ...)

if not MODE_FOLLOWER then
    skynet.start(function()
        local host = "0.0.0.0"
        local port = skynet.getenv("gate_port")

        local follower = {}
        local balance = 1
        local instance = 2

        for i = 1, instance do
            local sid = skynet.newservice(SERVICE_NAME, 1)
            table.insert(follower, sid)
        end

        local id = socket.listen(host, port)
        print("logind fd", host, port, id)
        socket.start(id, function(fd, addr)
            print("logind accept from", addr, fd)
            local s = follower[balance]
            balance = balance + 1
            if balance > #follower then
                balance = 1
            end

            skynet.send(s, "lua", fd, addr)
        end)
    end)
else
    local string, dump = string, dump
    local config_load = require "common.service.config_load"
    local proto = config_load.proto()
    local host = proto.host
    local callchild = require"server.login.login_common".callchild

    local send_package = function(fd, pack)
        local package = string.pack(">s2", pack)
        socket.write(fd, package)
    end

    local recv_data = function(fd)
        local len = socket.read(fd, 2)
        len = len:byte(1) * 256 + len:byte(2)
        local msg = socket.read(fd, len)
        return host:dispatch(msg)
    end

    local handle_req = function(fd, addr)
        socket.limit(fd, 4096)
        local t, cmd, req, res = recv_data(fd)
        print(t, cmd, dump(req), res)
        local acc = req.acc
        if not acc then
            return
        end

        local data = callchild(acc, cmd, req)
        socket.write(fd, string.pack(">s2", res(data)))
    end

    local handle = function(fd, addr)
        socket.start(fd)
        handle_req(fd, addr)
        socket.close(fd)
    end

    skynet.start(function()
        skynet.dispatch("lua", function(_, _, fd, addr)
            handle(fd, addr)
            skynet.ret(skynet.pack(true))
        end)
    end)
end

