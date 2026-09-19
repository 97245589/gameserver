local start = require "server.service.service"
local cluster = require "skynet.cluster"
local cmds = require "server.func.cmd"

local master = false

local dbserver = {}

start(function()
end, "sync")
