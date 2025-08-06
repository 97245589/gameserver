local mode = ...
if mode ~= "child" then
    return
end

local require = require
require "common.tool.lua_tool"
local print, dump = print, dump
local skynet = require "skynet"
local cluster = require "skynet.cluster"
local crypt = require "skynet.crypt"
local desencode = crypt.desencode
local zstd = require "common.tool.zstd"

local game_servers = {}
local acc_serverid = {}

local cmds = {
    game_servers = function(args)
        game_servers = args
        -- print("game_servers update", dump(args))
    end,
    login_req = function(acc, server)
        local bserver = acc_serverid[acc]
        if bserver and bserver ~= server then
            local addr = "game" .. bserver
            cluster.send(addr, "@" .. addr, "login_kick", acc)
        end
        acc_serverid[acc] = server

        local info = game_servers[server]
        local loginkey = info.loginkey
        local token = desencode(loginkey, zstd.pack({acc, skynet.time() * 1000}))
        return {
            code = 0,
            host = info.host,
            token = token
        }
    end

}

skynet.start(function()
    skynet.dispatch("lua", function(_, _, cmd, ...)
        local func = cmds[cmd]
        if func then
            skynet.retpack(func(...))
        else
            skynet.response()(false)
        end
    end)
end)
