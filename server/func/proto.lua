local sproto = require "sproto"

local pf = io.open("server/config/proto/game.proto")
local str = pf:read("*a")
pf:close()

local sp = sproto.parse(str)
local host = sp:host("package")
local req = host:attach(sp)

return { host = host, req = req }
