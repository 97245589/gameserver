local require = require
local skynet = require "skynet"
local client_req = require "server.game.player.client_req"
local cmds = require "common.service.cmds"

cmds.kick_player = client_req.kick_player
cmds.select_player = client_req.select_player
cmds.login_key = client_req.login_key

cmds.player_enter = function(playerid, fd, gate, acc)
    client_req.player_enter(fd, gate, acc, playerid)
end
