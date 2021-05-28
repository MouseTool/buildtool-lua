local tfmcmd = require("commands.tfmcmd")

local globals = require("bt-vars")
local btRoom = require("entities.bt_room")

tfmcmd.registerCommand(
    tfmcmd.Main {
        name = "map",
        aliases = {"np"},
        args = {
            tfmcmd.ArgString { lower = true, optional = true },
            tfmcmd.ArgString { lower = true, optional = true },
        },
        --- @param ctx tfmcmd.CmdContext
        --- @param w2? string
        --- @param w3? string
        func = function(ctx, w2, w3)
            if w2 == 'history' then
            elseif w2 == 'back' then
            else
                local T = {p4='#4',p8='#8'}
                if w2 then
                    tfm.exec.newGame(T[w2] or w2, w3=='mirror' and true or false)
                else
                    --mapsched.load(settings.maps.leisure[math.random(1,#settings.maps.leisure)]) roundvars.maptype = 'leisure'
                end
            end
        end
    }
)
tfmcmd.registerCommand(
    tfmcmd.Main {
        name = "rst",
        --- @param ctx tfmcmd.CmdContext
        func = function(ctx)
            local currentRound = btRoom.currentRound
            if not currentRound then
                local btp = globals.players[ctx.playerName]
                if btp then
                    btp:tlChatMsg("err_round_not_loaded")
                end
                return
            end
            tfm.exec.newGame(currentRound.mapCode)
        end
    }
)
