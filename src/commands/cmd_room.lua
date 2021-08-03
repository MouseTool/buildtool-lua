local tfmcmd = require("commands.tfmcmd")
local perms = require("commands.perms")
local ROLE = require("permissions.btPerms").ROLE

local btRoom = require("modules.btRoom")

tfmcmd.registerCommand(tfmcmd.Main {
    name = "pw",
    allowed = perms.IS_ROOMOWNER,
    visible = ROLE.ADMIN,
    args = {
        tfmcmd.ArgJoinedString { optional = true },
    },
    --- @param ctx tfmcmd.CmdContext
    --- @param password? string
    func = function(ctx, password)
        tfm.exec.setRoomPassword(password or "")
        btRoom.tlChatMsg(nil, password and "set_room_password" or "unset_room_password", ctx.playerName)
    end
})
