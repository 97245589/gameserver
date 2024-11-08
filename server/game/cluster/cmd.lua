local require, print = require, print
local skynet = require "skynet"
local cmds = require "common.service.cmds"

cmds.login_kick = function(acc)
    print("login_kick", acc)
end
