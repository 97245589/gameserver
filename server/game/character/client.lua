local skynet = require "skynet"
local socket = require "skynet.socket"
local proto = require "server.func.proto"
local service = require "server.game.service"
local mgr = require "server.game.character.mgr"
local host = proto.host
local push = proto.req
local string = string

local cid_fd = {}
local fd_cid = {}
local M = {}

local send_package = function(fd, str)
    socket.write(fd, string.pack(">s2", str))
end

M.kick = function(cid)
    local fd = cid_fd[cid]
    cid_fd[cid] = nil
    if fd then
        fd_cid[fd] = nil
        service.send("watchdog", "close_conn", fd)
    end
end

M.character_enter = function(cid, acc, fd, gate)
    print("character enter", cid, acc, fd, gate)
    M.kick(cid)
    skynet.send(gate, "lua", "forward", fd)
    cid_fd[cid] = fd
    fd_cid[fd] = cid
    local character = mgr.get_character(cid)
    character.id = cid
end

M.push = function(cid, name, args)
    local fd = cid_fd[cid]
    if not fd then
        return
    end
    send_package(fd, push(name, args, 0))
end

M.req = {}

local client_req = function(fd, cmd, args, resf)
    local cid = fd_cid[fd]
    local character = mgr.get_character(cid)

    local f = M.req[cmd]
    local ret = f(character, args) or { code = -1 }
    send_package(fd, resf(ret))
end

skynet.register_protocol({
    name = "client",
    id = skynet.PTYPE_CLIENT,
    unpack = function(msg, sz)
        return host:dispatch(msg, sz)
    end,
    dispatch = function(fd, _, _, cmd, ...)
        skynet.ignoreret()
        client_req(fd, cmd, ...)
    end
})

return M
