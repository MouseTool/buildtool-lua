local tfmcmd = require("commands.tfmcmd")
local perms = require("commands.perms")

local btRoom = require("entities.bt_room")

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
            for _, btp in pairs(btRoom.players) do
                btp:normalRespawn()
            end
            return
        end
        local btp = btRoom.players[target or ctx.playerName]
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
        local btp = btRoom.players[ctx.playerName]
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
            for name, btp in pairs(btRoom.players) do
                tfm.exec.killPlayer(name)
            end
            return
        end
        local btp = btRoom.players[target or ctx.playerName]
        if not btp then return end
        tfm.exec.killPlayer(btp.name)
    end
})

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
