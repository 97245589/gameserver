local skynet = require "skynet"
require "skynet.manager"
require "server.func.print"

local gen_pairs = function(tarr, spacenum)
    local s = "\n"
    for i = 1, spacenum do
        s = s .. "    "
    end
    local e = "\n"
    for i = 2, spacenum do
        e = e .. "    "
    end
    local rarr = {}
    for idx, p in ipairs(tarr) do
        local lf = s .. "%s %s : %s"
        local ts = p[2]
        if p[3] then
            if p[4] then
                ts = "*" .. p[2] .. "(" .. p[4] .. ")"
            else
                ts = "*" .. p[2]
            end
        end
        local l = string.format(lf, p[1], idx, ts)
        table.insert(rarr, l)
    end
    return table.concat(rarr) .. e
end

local pidx = 0
local h = {
    struct = function(t)
        local fstr = [[
.%s {%s}
]]
        return string.format(fstr, t[2], gen_pairs(t[3], 1))
    end,
    proto = function(t)
        local pstr = [[
%s %s {
    request {%s}
    response {%s}
}
]]
        pidx = pidx + 1
        return string.format(pstr, t[2], pidx, gen_pairs(t[3], 2), gen_pairs(t[4], 2))
    end
}
local pname = "server/config/proto/game.proto"
os.remove(pname)
local pf = io.open(pname, "a")
local cp_cb = function(s, pos, t)
    -- print(dump(t))
    local r = h[t[1]](t)
    pf:write(r)
    return true
end

local parse_proto = function()
    local lpeg = require "lpeg"
    lpeg.locale(lpeg)
    local identifier = (lpeg.alpha + "_") * (lpeg.alpha + lpeg.alnum + "_") ^ 0
    local space = lpeg.space ^ 0
    local name = space * lpeg.C(identifier) * space
    local tp = space * lpeg.C(identifier) * (space * lpeg.C("[") * space * lpeg.C(identifier) ^ -1 * space * "]") ^ -1 *
        space

    local pair = lpeg.Ct(name * ":" * tp * space)
    local pairs = space * "{" * lpeg.Ct(pair ^ 0) * "}" * space

    local struct = name * name * pairs
    local proto = name * name * "{" * pairs * pairs * "}" * space
    local ele = lpeg.Cmt(lpeg.Ct(struct + proto), cp_cb)
    local eles = ele ^ 0

    local f = io.open("server/config/proto/proto.base")
    local str = f:read("*a")
    f:close()
    eles:match(str)
end

skynet.start(function()
    parse_proto()
    pf:close()
    skynet.abort()
end)
