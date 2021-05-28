local tfmcmd = require("commands.tfmcmd")

local globals = require("bt-vars")

tfmcmd.registerCommand(tfmcmd.Main {
    name = "score",
    args = {
        tfmcmd.ArgString { optional = true },
        tfmcmd.ArgString { optional = true },
    },
    --- @param ctx tfmcmd.CmdContext
    --- @param w2? string
    --- @param w3? string
    func = function(ctx, w2, w3)
        local invoker = globals.players[ctx.playerName]
        if not invoker then return end

        local score = tonumber(w2) or tonumber(w3) or 0
        local target = not tonumber(w2) and w2 or ctx.playerName
        if score < 0 or score > 999 then
            invoker:tlChatMsg("err_score_not_ranged", 0, 999)
        elseif w2 == "all" or w3 == "all" then
            for name, btp in pairs(globals.players) do
                tfm.exec.setPlayerScore(name, score)
            end
        elseif w2 == "me" or w3 == "me" then
            tfm.exec.setPlayerScore(ctx.playerName, score)
        else
            tfm.exec.setPlayerScore(target, score)
        end
    end
})
tfmcmd.registerCommand(tfmcmd.Main {
    name = "s",
    args = {
        tfmcmd.ArgString { optional = true },
    },
    --- @param ctx tfmcmd.CmdContext
    --- @param target? string
    func = function(ctx, target)
        local targetp = globals.players[target or ctx.playerName]
        if not targetp then return end

        local highest_score = nil
        for _, btp in pairs(globals.players) do
            local score = btp.mbp:getTfmPlayer().score
            if not highest_score or score > highest_score then
                highest_score = score
            end
        end

        tfm.exec.setPlayerScore(targetp.name, highest_score + 1)
    end
})
