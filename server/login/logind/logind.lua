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
    local string, split, dump = string, split, dump
    local config_load = require "common.service.config_load"
    local login_common = require "server.login.login_common"
    local service_config = require "common.service.service_config"
    local crypt = require "skynet.crypt"
    local proto = config_load.proto()
    local host = proto.host
    local callchild = login_common.callchild
    local key = service_config.login_service_key

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

    local verify = function(acc, token)
        local arr = split(crypt.desdecode(key, token), "|")
        if acc ~= arr[1] then
            return
        end
        return true
    end

    local handle_req = function(fd, addr)
        socket.limit(fd, 4096)
        local t, cmd, req, res = recv_data(fd)
        if not cmd or not req or not req.acc or not req.token then
            return
        end
        local acc, token = req.acc, req.token
        if not verify(acc, token) then
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

