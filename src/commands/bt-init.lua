local tfmcmd = require("commands.tfmcmd")
local cmdPerms = require("commands.perms")

local btRoom = require("entities.bt_room")
local globals = require("bt-vars")
local api = globals.api
local tfmEvent = api.tfmEvent

tfmcmd.setDefaultAllow(cmdPerms.IS_ADMIN)

-- Init commands
require("commands.cmd_map")
require("commands.cmd_debug")
require("commands.cmd_respawn_mort")
require("commands.cmd_sham")
require("commands.cmd_score")

tfmEvent:on("ChatCommand", function(pn, msg)
    btRoom.moduleMsgDirect(("<G>[%s] !%s"):format(pn, msg))

    local ret, retmsg = tfmcmd.executeChatCommand(pn, msg)
	if ret ~= tfmcmd.OK then
		local default_msgs = {
			[tfmcmd.ENOCMD] = "no command found",
            [tfmcmd.EPERM] = "no permission",
            [tfmcmd.EMISSING] = "missing argument",
            [tfmcmd.EINVAL] = "invalid argument"
        }
        btRoom.moduleMsgDirect(retmsg or default_msgs[ret] or "", pn)
    end
end)
