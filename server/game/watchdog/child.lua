local skynet = require "skynet"
local mode, watchdog, gate = ...

if mode == "child" then
    print = skynet.error
    local service = require "server.game.service"

    local handle = {
        verify = function(args, fd, acc)
            skynet.send(watchdog, "lua", "verify_success", fd, acc)
        end,
        choose = function(args, fd, acc)
            local chid = args.chid
            service.call_id("character", "enter", chid, fd, acc)
        end,
        create_player = function(args, fd, acc)
        end
    }
    skynet.start(function()
        skynet.dispatch("lua", function(_, _, fd, msg, acc)
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
