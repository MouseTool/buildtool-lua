local tfmcmd = require("commands.tfmcmd")

--local WindowManager = require("window.window_manager")
local WindowEnum = require("btEnums").Window
local btRoom = require("modules.btRoom")

tfmcmd.registerCommand(tfmcmd.Main {
    name = "help",
    allowed = true,
    args = {},
    --- @param ctx tfmcmd.CmdContext
    func = function(ctx)
        WindowManager.open(WindowEnum.HELP)
    end
})

tfmcmd.registerCommand(tfmcmd.Main {
    name = "mapinfo",
    aliases = {"info"},
    allowed = true,
    visible = false,
    args = {},
    --- @param ctx tfmcmd.CmdContext
    func = function(ctx)
        local currentRound = btRoom.currentRound
        if not currentRound then
            local btp = btRoom.players[ctx.playerName]
            if btp then
                btp:tlChatMsg("chat.err_round_not_loaded")
            end
            return
        end
        currentRound:sendMapInfo(ctx.playerName)
    end
})
