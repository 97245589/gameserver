local skynet = require "skynet"

local playerid_fd = {}
local fd_playerid = {}
local reqs = {}

local M = {
    reqs = reqs
}

local send_package = function(fd, pack)

end

skynet.register_protocol({
    name = "client",
    id = skynet.PTYPE_CLIENT,
    unpack = function(msg, sz)
    end,
    dispatch = function(fd, _, type, cmd, ...)
        skynet.ignoreret()
    end
})

return M
