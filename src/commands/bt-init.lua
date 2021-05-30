local tfmcmd = require("commands.tfmcmd")
local cmdPerms = require("commands.perms")

local btRoom = require("entities.bt_room")
local api = btRoom.api
local tfmEvent = api.tfmEvent

tfmcmd.setDefaultAllow(cmdPerms.IS_ADMIN)

-- Init commands
require("commands.cmd_map")
require("commands.cmd_debug")
require("commands.cmd_respawn_mort")
require("commands.cmd_sham")
require("commands.cmd_score")
require("commands.cmd_clear")
require("commands.cmd_room")

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
