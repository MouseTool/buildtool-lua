local tfmcmd = require("tfmcmd")
local cmdPerms = require("perms")

local btRoom = require("modules.btRoom")
local api = btRoom.api
local tfmEvent = api.tfmEvent

tfmcmd.setDefaultAllow(cmdPerms.IS_ADMIN)

-- Init commands
require("cmd_debug")
require("cmd_interface")
require("cmd_room")
require("cmd_rotation")
require("cmd_utility")

tfmEvent:on("ChatCommand", function(pn, msg)
    local btp = btRoom.players[pn]
    local vis = tfmcmd.getVisible(msg)
    if vis ~= false then
        local g = vis
        if vis == true then g = nil end
        btRoom.chatMsg(("<G>[%s] !%s"):format(pn, msg), g)
    end

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
