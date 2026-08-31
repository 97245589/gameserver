local skynet = require "skynet"
local crypt = require "skynet.crypt"
local socket = require "skynet.socket"
local proto = require "server.func.proto"

local host = proto.host
local req = proto.req

local session = 0
local send_req = function(fd, name, args)
    if session >= 0xffff then
        session = 0
    end
    session = session + 1
    local str = req(name, args, session)
    socket.write(fd, string.pack(">s2", str))
    return name, session
end

local get_res = function(fd)
    local lendata = socket.read(fd, 2)
    local len = lendata:byte(1) * 256 + lendata:byte(2)
    local msg = socket.read(fd, len)
    return host:dispatch(msg)
end

--[[
info={loginhost=,gamehost=,acc=,cid=}
]]
local clogin = function(info)
    local loginhost = info.loginhost
    local gamehost = info.gamehost
    local acc = info.acc
    local cid = info.cid
    local conn_login = function()
        if not loginhost then
            return
        end
        local fd = socket.open(loginhost)
        local cpri = crypt.randomkey()
        local cpub = crypt.dhexchange(cpri)
        send_req(fd, "exchange", {
            cpub = cpub
        })
        local _, _, args, _ = get_res(fd)
        local secret = crypt.dhsecret(args.spub, cpri)
        send_req(fd, "login_verify", {
            acc = acc,
            token = crypt.desencode(secret, acc)
        })
        get_res(fd)
        send_req(fd, "select_gameserver", {
            serverid = 1
        })
        get_res(fd)
        skynet.sleep(1)
        return secret
    end

    local conn_game = function()
        local secret = conn_login()
        local fd = socket.open(gamehost)
        send_req(fd, "verify", {
            acc = acc, token = secret and crypt.desencode(secret, acc)
        })
        get_res(fd)
        skynet.sleep(1)
        send_req(fd, "select_character", {
            characterid = cid
        })
        get_res(fd)
        return fd
    end

    return conn_game()
end

return {
    clogin = clogin,
    send_req = send_req,
    get_res = get_res
}
