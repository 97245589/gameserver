require "server.func.print"
local skynet = require "skynet"
local socket = require "skynet.socket"
local proto = require "server.func.proto"

local host = proto.host
local req = proto.req

local session = 0
local send_req = function(fd, name, args)
    session = session + 1
    if session < 1 or session > 120 then
        session = 1
    end
    local str = req(name, args, session)
    socket.write(fd, string.pack(">s2", str))
    return name, session
end

local get_res = function(fd)
    local lendata = socket.read(fd, 2)
    local len = lendata:byte(1) * 256 + lendata:byte(2)
    local msg = socket.read(fd, len)
    local r1, r2, r3, r4 = host:dispatch(msg)
    print(r1, r2, dump(r3), r4)
end

local conn_game = function()
    local fd = socket.open("0.0.0.0:10012")

    send_req(fd, "verify", {
        acc = "hhh", token = ""
    })
    get_res(fd)

    send_req(fd, "select_character", {
        characterid = 100
    })
    get_res(fd)

    send_req(fd, "req_test", {
        req = "hello world"
    })

    skynet.fork(function()
        while true do
            get_res(fd)
        end
    end)
end

skynet.start(function()
    conn_game()
end)
