require "common.func.tool"
local require = require
local print = print
local dump = dump
local string = string
local skynet = require "skynet"
local socket = require "skynet.socket"

local load_proto = function()
    local sproto = require "sproto"
    local s2c_f = io.open("config/s2c.sproto")
    local c2s_f = io.open("config/c2s.sproto")
    local s2c_str = s2c_f:read("*a")
    local c2s_str = c2s_f:read("*a")
    s2c_f:close()
    c2s_f:close()
    local host = sproto.parse(s2c_str):host("package")
    local req = host:attach(sproto.parse(c2s_str))
    return host, req
end
local host, req_pack = load_proto()
local session = 0

local request = function(fd, name, args)
    session = session + 1
    local str = req_pack(name, args, session)
    socket.write(fd, string.pack(">s2", str))
    return name, session
end

local recv_data = function(fd)
    local lendata = socket.read(fd, 2)
    local len = lendata:byte(1) * 256 + lendata:byte(2)
    local msg = socket.read(fd, len)
    return host:dispatch(msg)
end

local print_proto = function(tp, sid, tb)
    print(tp, sid, dump(tb))
end

local conn_gameserver = function()
    local acc = "acc"
    local playerid = "100"
    local fd = socket.open("127.0.0.1", 10012)
    request(fd, "verify", {
        acc = acc
    })
    print_proto(recv_data(fd))
    request(fd, "select_player", {
        playerid = playerid
    })
    print_proto(recv_data(fd))

    request(fd, "get_data", {})
    skynet.fork(function()
        while true do
            print_proto(recv_data(fd))
        end
    end)
end

skynet.start(function()
    conn_gameserver()
end)
