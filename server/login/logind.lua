local mode = ...
local skynet = require "skynet"
local cluster = require "skynet.cluster"
local socket = require "skynet.socket"
require "server.func.print"

if mode == "child" then
    local proto = require "server.func.proto"
    local crypt = require "skynet.crypt"

    local host = proto.host
    local spack = string.pack

    local send_package = function(fd, pack)
        local package = spack(">s2", pack)
        socket.write(fd, package)
    end

    local get_req = function(fd)
        local len = socket.read(fd, 2)
        len = len:byte(1) * 256 + len:byte(2)
        local msg = socket.read(fd, len)
        return host:dispatch(msg)
    end

    local exchange = function(fd, spub)
        local _, name, args, res = get_req(fd)
        local cpub = args.cpub
        if not cpub then
            return
        end
        send_package(fd, res({
            code = 0,
            spub = spub
        }))
        return cpub
    end

    local select_gameserver = function(fd, secret)
        local _, name, args, res = get_req(fd)
        local arr = args.arr
        local token = args.token
        local serverid = args.serverid
        if not arr or not token or not serverid then
            return
        end
        local acc = arr[1]
        local str = acc .. arr[2]
        -- print("verify", str == crypt.desdecode(secret, token))
        if str ~= crypt.desdecode(secret, token) then
            return
        end

        local server = "game" .. serverid
        skynet.send("login", "lua", "acc_server", acc, server)
        cluster.call(server, "watchdog", "acc_secret", acc, secret)

        send_package(fd, res({
            code = 0,
        }))
        return true
    end

    local login = function(fd, addr)
        local spri = crypt.randomkey()
        local spub = crypt.dhexchange(spri)

        local cpub = exchange(fd, spub)
        if not cpub then
            return
        end
        local secret = crypt.dhsecret(cpub, spri)
        if not select_gameserver(fd, secret) then
            return
        end
    end

    skynet.start(function()
        skynet.dispatch("lua", function(_, _, fd, addr)
            socket.start(fd)
            socket.limit(fd, 4096)
            local ok, err = pcall(login, fd, addr)
            if not ok then
                print("login err", err)
            end
            socket.close(fd)
            skynet.response()(false)
        end)
    end)
else
    local addrs = {}
    local childnum = 10

    for i = 1, childnum do
        local addr = skynet.newservice("server/login/logind", "child")
        table.insert(addrs, addr)
    end

    local gate_port = skynet.getenv("gate_port")
    local id = socket.listen("0.0.0.0", gate_port)
    socket.start(id, function(fd, addr)
        local s = addrs[fd % childnum + 1]
        skynet.send(s, "lua", fd, addr)
    end)
end
