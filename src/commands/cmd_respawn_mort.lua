local tfmcmd = require("commands.tfmcmd")

local globals = require("bt-vars")

tfmcmd.registerCommand(tfmcmd.Main {
    name = "respawn",
    aliases = {"r"},
    args = {
        tfmcmd.ArgString { optional = true },
    },
    --- @param ctx tfmcmd.CmdContext
    --- @param target? string
    func = function(ctx, target)
        if target == "all" then
            for _, btp in pairs(globals.players) do
                btp:normalRespawn()
            end
            return
        end
        local btp = globals.players[target or ctx.playerName]
        if not btp then return end
        btp:normalRespawn()
    end
})
tfmcmd.registerCommand(tfmcmd.Main {
    name = "mort",
    aliases = {"m"},
    allowed = true,
    --- @param ctx tfmcmd.CmdContext
    func = function(ctx)
        local btp = globals.players[ctx.playerName]
        if not btp then return end
        tfm.exec.killPlayer(ctx.playerName)
    end
})
tfmcmd.registerCommand(tfmcmd.Main {
    name = "kill",
    args = {
        tfmcmd.ArgString { optional = true },
    },
    --- @param ctx tfmcmd.CmdContext
    --- @param target? string
    func = function(ctx, target)
        if target == "all" then
            for name, btp in pairs(globals.players) do
                tfm.exec.killPlayer(name)
            end
            return
        end
        local btp = globals.players[target or ctx.playerName]
        if not btp then return end
        tfm.exec.killPlayer(btp.name)
    end
})
