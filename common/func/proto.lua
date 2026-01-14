local sproto = require "sproto"

local file = io.open("config/game.sproto", "r")
local str = file:read("*a")
file:close()
local sp = sproto.parse(str)
local host = sp:host("package")

return {
    sp = sp,
    host = host,
    push = host:attach(sp)
}
