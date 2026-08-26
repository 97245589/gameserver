local cmd = require "server.func.cmd"
local client = require "server.game.character.client"
local wdata = require "server.game.character.wdata"

cmd.character_enter = client.character_enter
cmd.watchdog_data = wdata.watchdog_data
