local skynet = require "skynet"
require "skynet.manager"
require "server.func.print"

local parse_proto = function()
    local lpeg = require "lpeg"
    lpeg.locale(lpeg)
    local identifier = (lpeg.alpha + "_") * (lpeg.alpha + lpeg.alnum + "_") ^ 0
    local space = lpeg.space ^ 0
    local name = space * lpeg.C(identifier) * space
    local pair = space * name * ":" * name * space
    local pairs = space * "{" * lpeg.Ct(pair ^ 0) * "}" * space

    local sinfo = [[
        struct player {
            role:role rela:rela int:integer str:string num:number
        }
    ]]
    local struct = lpeg.Ct(name * name * pairs)
    -- print(dump(struct:match(sinfo)))

    local pinfo = [[
        proto enter {
            {characterid:integer}
            {player:player}
        }
    ]]
    local proto = lpeg.Ct(name * name * "{" * pairs * pairs * "}")
    print(dump(proto:match(pinfo)))
end

skynet.start(function()
    parse()
    -- skynet.abort()
end)
