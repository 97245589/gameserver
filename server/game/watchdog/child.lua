local skynet = require "skynet"
local mode, watchdog, gate = ...

if mode == "child" then
    require "server.func.print"
    local service = require "server.game.service"
    local socket = require "skynet.socket"
    local proto = require "server.func.proto"

    local host = proto.host
    local close_conn = function(fd)
        skynet.send(watchdog, "lua", "close_conn", fd)
    end

    local handle = {
        verify = function(args, fd)
            skynet.call(watchdog, "lua", "verify_success", fd, args.acc)
            return { code = 1 }
        end,
        select_character = function(args, fd, acc)
            local characterid = args.characterid
            service.call_id("character", "character_enter", characterid, acc, fd, gate)
            return { code = 1 }
        end
    }
    skynet.start(function()
        skynet.dispatch("lua", function(_, _, fd, msg, acc)
            local _, cmd, args, resf = host:dispatch(msg)
            local f = handle[cmd]
            local ret = f(args, fd, acc) or {
                code = -1
            }
            socket.write(fd, string.pack(">s2", resf(ret)))
        end)
    end)
else
    local addrs = {}
    local cnum
    return {
        start = function(num, gate_addr)
            cnum = num
            local waddr = skynet.self()
            for i = 1, cnum do
                local addr = skynet.newservice("server/game/watchdog/child", "child", waddr, gate_addr)
                table.insert(addrs, addr)
            end
        end,
        data = function(fd, msg, acc)
            local addr = addrs[fd % cnum + 1]
            skynet.send(addr, "lua", fd, msg, acc)
        end
    }
end
