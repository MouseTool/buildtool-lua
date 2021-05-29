local tfmcmd = require("commands.tfmcmd")
local perms = require("commands.perms")

local btRoom = require("entities.bt_room")

tfmcmd.registerCommand(tfmcmd.Main {
    name = "clear",
    allowed = perms.IS_SHAM_OR_ADMIN,
    args = {
        tfmcmd.ArgString { optional = true, lower = true },
    },
    --- @param ctx tfmcmd.CmdContext
    --- @param all? string
    func = function(ctx, all)
        local round = btRoom.currentRound
        local is_all = (all == "all")
        if round then
            if is_all then
                round:clearAllObjects()
            else
                round:clearAllObjects(ctx.playerName)
            end
        end
    end
})
