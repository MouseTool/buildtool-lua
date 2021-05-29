local tfmcmd = require("commands.tfmcmd")

local btRoom = require("entities.bt_room")

tfmcmd.registerCommand(tfmcmd.Interface {
    commands = {"sham", "unsham"},
    args = {
        tfmcmd.ArgString { optional = true },
    },
    --- @param ctx tfmcmd.CmdContext
    --- @param target? string
    func = function(ctx, target)
        local should_set = ctx.commandName ~= "unsham"
        if target == "all" then
            for name, btp in pairs(btRoom.players) do
                tfm.exec.setShaman(name, should_set)
            end
            return
        end
        local btp = btRoom.players[target or ctx.playerName]
        if not btp then return end
        tfm.exec.setShaman(btp.name, should_set)
    end
})

