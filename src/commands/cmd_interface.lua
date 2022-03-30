local tfmcmd = require("commands.tfmcmd")
local HelpWindow = require("window.HelpWindow")

--local WindowManager = require("window.window_manager")
local WindowEnums = require("btEnums").Window
local btRoom = require("modules.btRoom")

tfmcmd.registerCommand(tfmcmd.Main {
    name = "help",
    allowed = true,
    args = {},
    --- @param ctx tfmcmd.CmdContext
    func = function(ctx)
        local btp = btRoom.players[ctx.playerName]
        if not btp then return end

        if btp.windowRegistry:isOpen(WindowEnums.HELP) then
            btp.windowRegistry:close(WindowEnums.HELP)
            return
        end
        btp.windowRegistry:open(
            WindowEnums.HELP,
            HelpWindow:new():controlFor(btp.name)
        )
    end
})

tfmcmd.registerCommand(tfmcmd.Main {
    name = "mapinfo",
    aliases = { "info" },
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
